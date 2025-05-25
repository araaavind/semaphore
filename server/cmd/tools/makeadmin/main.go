package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/aravindmathradan/semaphore/internal/data"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	var (
		dsn      = flag.String("dsn", os.Getenv("SEMAPHORE_DB_DSN"), "PostgreSQL connection string")
		username = flag.String("username", "", "Username of the user to make admin")
		revoke   = flag.Bool("revoke", false, "Flag to revoke admin permissions")
	)

	flag.Parse()

	if *username == "" {
		log.Fatal("Error: username is required")
	}

	db, err := openDB(*dsn)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	models := data.NewModels(db)

	user, err := models.Users.GetByUsername(*username)
	if err != nil {
		if errors.Is(err, data.ErrRecordNotFound) {
			log.Fatalf("Error: user %s not found", *username)
		}
		log.Fatalf("Error: %s", err)
	}

	if !user.Activated {
		log.Fatal("Error: user must be activated before granting them admin privileges")
	}

	err = models.Permissions.CreateIfNotExists(data.PermissionAllAdmin)
	if err != nil {
		log.Fatalf("Error: %s", err)
	}

	if *revoke {
		err = models.Permissions.RemoveForUser(user.ID, data.PermissionAllAdmin)
		if err != nil {
			if errors.Is(err, data.ErrRecordNotFound) {
				log.Fatalf("Error: user %s does not have admin privileges", *username)
			}
			log.Fatalf("Error: %s", err)
		}

		fmt.Printf("Successfully revoked admin privileges from user: %s\n", *username)
	} else {
		err = models.Permissions.AddForUser(user.ID, data.PermissionAllAdmin)
		if err != nil {
			if errors.Is(err, data.ErrUniqueConstraint) {
				log.Fatalf("Error: user %s already has admin privileges", *username)
			}
			log.Fatalf("Error: %s", err)
		}

		fmt.Printf("Successfully granted admin privileges to user: %s\n", *username)
	}
}

func openDB(dsn string) (*pgxpool.Pool, error) {
	poolConfig, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		return nil, err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()

	db, err := pgxpool.NewWithConfig(ctx, poolConfig)
	if err != nil {
		return nil, err
	}

	err = db.Ping(ctx)
	if err != nil {
		db.Close()
		return nil, err
	}

	return db, nil
}
