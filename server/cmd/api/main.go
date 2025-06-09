package main

import (
	"context"
	"expvar"
	"flag"
	"fmt"
	"log/slog"
	"os"
	"runtime"
	"strings"
	"sync"
	"time"

	"github.com/aravindmathradan/semaphore/internal/cache"
	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/aravindmathradan/semaphore/internal/mailer"
	"github.com/aravindmathradan/semaphore/internal/vcs"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/mmcdole/gofeed"
	"github.com/redis/go-redis/v9"
)

var (
	version = vcs.Version()
)

type config struct {
	port int
	env  string
	db   struct {
		dsn          string
		maxOpenConns int
		maxIdleConns int
		maxIdleTime  time.Duration
	}
	redis struct {
		dsn      string
		db       int
		poolSize int
	}
	smtp struct {
		host     string
		port     int
		username string
		password string
		sender   string
	}
	limiter struct {
		rps     float64
		burst   int
		enabled bool
	}
	refresher struct {
		userAgent              string
		maxConcurrentRefreshes int
		refreshStaleFeedsSince time.Duration
		refreshPeriod          time.Duration
	}
	cleanup struct {
		tokensCleanupPeriod        time.Duration
		itemsCleanupPeriod         time.Duration
		itemsCleanupBeforeDuration time.Duration
	}
	cors struct {
		trustedOrigins []string
	}
	google struct {
		clientID      string
		youtubeAPIKey string
	}
}

type application struct {
	config config
	logger *slog.Logger
	models data.Models
	cache  cache.Cache
	parser *gofeed.Parser
	mailer mailer.Mailer
	wg     sync.WaitGroup
	ctx    context.Context
	cancel context.CancelFunc
}

func main() {
	var cfg config

	flag.IntVar(&cfg.port, "port", 4000, "API server port")
	flag.StringVar(&cfg.env, "env", "development", "Environment (development|staging|production)")

	flag.StringVar(&cfg.db.dsn, "dsn", os.Getenv("SEMAPHORE_DB_DSN"), "PostgreSQL connection string")
	flag.IntVar(&cfg.db.maxOpenConns, "db-max-open-conns", 25, "PostgreSQL max open connections")
	flag.IntVar(&cfg.db.maxIdleConns, "db-max-idle-conns", 25, "PostgreSQL max idle connections")
	flag.DurationVar(&cfg.db.maxIdleTime, "db-max-idle-time", 15*time.Minute, "PostgreSQL max connection idle time (default: 15m)")

	flag.StringVar(&cfg.redis.dsn, "redis-dsn", os.Getenv("REDIS_DSN"), "Redis connection string")
	flag.IntVar(&cfg.redis.db, "redis-db", 0, "Redis database number")
	flag.IntVar(&cfg.redis.poolSize, "redis-pool-size", 10, "Redis connection pool size")
	flag.StringVar(&cfg.smtp.host, "smtp-host", "sandbox.smtp.mailtrap.io", "SMTP host")
	flag.IntVar(&cfg.smtp.port, "smtp-port", 2525, "SMTP port")
	flag.StringVar(&cfg.smtp.username, "smtp-username", "", "SMTP username")
	flag.StringVar(&cfg.smtp.password, "smtp-password", "", "SMTP password")
	flag.StringVar(&cfg.smtp.sender, "smtp-sender", "Semaphore <no-reply@smphr.aravindunnikrishnan.in>", "SMTP sender")

	flag.Float64Var(&cfg.limiter.rps, "limiter-rps", 4, "Rate limiter maximum requests per second")
	flag.IntVar(&cfg.limiter.burst, "limiter-burst", 8, "Rate limiter maximum burst")
	flag.BoolVar(&cfg.limiter.enabled, "limiter-enabled", true, "Enable rate limiter")

	flag.StringVar(&cfg.refresher.userAgent, "user-agent", os.Getenv("FETCHER_USER_AGENT"), "User agent for feed fetching")
	flag.IntVar(&cfg.refresher.maxConcurrentRefreshes, "max-concurrent-refreshes", 5, "Maximum concurrent refreshes")
	flag.DurationVar(&cfg.refresher.refreshStaleFeedsSince, "refresh-since", 5*time.Minute, "Refresh stale feeds since (default: 5m)")
	flag.DurationVar(&cfg.refresher.refreshPeriod, "refresh-period", time.Minute, "Refresh feed period (default: 1m)")

	flag.DurationVar(&cfg.cleanup.tokensCleanupPeriod, "tokens-cleanup-period", time.Hour*12, "Tokens cleanup period (default: 12h)")
	flag.DurationVar(&cfg.cleanup.itemsCleanupPeriod, "items-cleanup-period", time.Hour*12, "Items cleanup period (default: 12h)")
	flag.DurationVar(&cfg.cleanup.itemsCleanupBeforeDuration, "items-cleanup-before-duration", time.Hour*24*30, "Items cleanup before duration (default: 30d)")

	flag.Func("cors-trusted-origins", "Trusted CORS origins (space separated within double quotes)", func(val string) error {
		cfg.cors.trustedOrigins = strings.Fields(val)
		return nil
	})

	flag.StringVar(&cfg.google.clientID, "google-client-id", "", "Google OAuth web client ID")
	flag.StringVar(&cfg.google.youtubeAPIKey, "youtube-api-key", os.Getenv("YOUTUBE_API_KEY"), "YouTube Data API key")

	// Create a new version boolean flag with the default value of false.
	displayVersion := flag.Bool("version", false, "Display version and exit")

	flag.Parse()

	fmt.Println("cfg.refresher.userAgent: ", cfg.refresher.userAgent)

	// If the version flag value is true, then print out the version number and
	// immediately exit.
	if *displayVersion {
		fmt.Printf("Version:\t%s\n", version)
		os.Exit(0)
	}

	logger := slog.New(slog.NewTextHandler(os.Stdout, nil))

	db, err := openDB(cfg)
	if err != nil {
		logger.Error(err.Error())
		os.Exit(1)
	}
	defer db.Close()

	logger.Info("database connection pool established")

	rdb, err := initRedis(cfg)
	if err != nil {
		logger.Error(err.Error())
		os.Exit(1)
	}
	defer rdb.Close()

	logger.Info("redis connection pool established")

	expvar.NewString("version").Set(version)
	expvar.Publish("goroutines", expvar.Func(func() any {
		return runtime.NumGoroutine()
	}))

	expvar.Publish("database", expvar.Func(func() any {
		return db.Stat()
	}))

	expvar.Publish("redis", expvar.Func(func() any {
		return rdb.PoolStats()
	}))

	expvar.Publish("timestamp", expvar.Func(func() any {
		return time.Now().Unix()
	}))

	feedParser := gofeed.NewParser()
	feedParser.UserAgent = cfg.refresher.userAgent

	app := &application{
		config: cfg,
		logger: logger,
		models: data.NewModels(db),
		cache:  cache.NewRedisCache(rdb),
		parser: feedParser,
		mailer: mailer.New(
			cfg.smtp.host,
			cfg.smtp.port,
			cfg.smtp.username,
			cfg.smtp.password,
			cfg.smtp.sender,
		),
	}

	// Create a new context which is cancelled on graceful shutdown
	app.ctx, app.cancel = context.WithCancel(context.Background())

	// Start the feed refresher in the background
	app.background(func() {
		app.KeepFeedsFresh()
	})

	// Start the tokens cleanup in the background
	app.background(func() {
		app.CleanupTokens()
	})

	// Start the items cleanup in the background
	app.background(func() {
		app.CleanupOldUnsavedItems()
	})

	err = app.serve()
	if err != nil {
		logger.Error(err.Error())
		os.Exit(1)
	}
}

func openDB(cfg config) (*pgxpool.Pool, error) {
	poolConfig, err := pgxpool.ParseConfig(cfg.db.dsn)
	if err != nil {
		return nil, err
	}

	poolConfig.MaxConns = int32(cfg.db.maxOpenConns)
	poolConfig.MaxConnIdleTime = cfg.db.maxIdleTime

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	db, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		return nil, err
	}

	err = db.Ping(ctx)
	if err != nil {
		defer db.Close()
		return nil, err
	}

	return db, nil
}

func initRedis(cfg config) (*redis.Client, error) {
	options, err := redis.ParseURL(cfg.redis.dsn)
	if err != nil {
		return nil, err
	}
	options.DB = cfg.redis.db
	options.PoolSize = cfg.redis.poolSize

	rdb := redis.NewClient(options)

	// Test Redis connection
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	if err := rdb.Ping(ctx).Err(); err != nil {
		return nil, err
	}

	return rdb, nil
}
