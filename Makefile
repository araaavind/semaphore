# Include variables from the .envrc file
include .envrc


# ==================================================================================== #
# HELPERS
# ==================================================================================== #

## help: print this help message
.PHONY: help
help:
	@echo 'Usage:'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /'

.PHONY: confirm
confirm:
	@echo -n 'Are you sure? [y/N] ' && read ans && [ $${ans:-N} = y ]


# ==================================================================================== #
# DEVELOPMENT
# ==================================================================================== #

## run/api: run the cmd/api application in development mode
.PHONY: run/api
run/api:
	@echo 'Starting api server...'
	cd server && go run ./cmd/api -dsn=${SEMAPHORE_DSN} -smtp-username=${SMTP_USERNAME} -smtp-password=${SMTP_PASSWORD}

## db/migrations/version: check current database migration version
.PHONY: db/migrations/version
db/migrations/version:
	goose -dir ./server/migrations postgres ${SEMAPHORE_DSN} version
	
## db/migrations/new name=$1: create a new database migration
.PHONY: db/migrations/new
db/migrations/new:
	@echo 'Creating a migration file for ${name}'
	goose -s -dir ./server/migrations create ${name} sql

## db/migrations/up: apply all up database migrations
.PHONY: db/migrations/up
db/migrations/up: confirm
	@echo 'Running up migrations...'
	goose -dir ./server/migrations postgres ${SEMAPHORE_DSN} up

## db/migrations/down: apply a down database migration
.PHONY: db/migrations/down
db/migrations/down: confirm
	@echo 'Running down migrations...'
	goose -dir ./server/migrations postgres ${SEMAPHORE_DSN} down


# ==================================================================================== #
# QUALITY CONTROL
# ==================================================================================== #

## audit: tidy dependencies and format, vet and test all code
.PHONY: audit
audit: vendor
	@echo 'Formatting code...'
	cd server && go fmt ./...
	@echo 'Vetting code...'
	cd server && go vet ./...
	cd server && staticcheck ./...
	@echo 'Running tests...'
	cd server && go test -race -vet=off ./...

## vendor: tidy and vendor dependencies
.PHONY: vendor
vendor:
	@echo 'Tidying and verifying module dependencies...'
	cd server && go mod tidy
	cd server && go mod verify
	@echo 'Vendoring dependencies...'
	cd server && go mod vendor


# ==================================================================================== #
# BUILD
# ==================================================================================== #

## build/api: build the cmd/api application for local machine and linux/amd64
.PHONY: build/api
build/api:
	@echo 'Building cmd/api for local machine...'
	cd server && go build -ldflags='-s -w' -o=./bin/local/api ./cmd/api
	@echo 'Building cmd/api for deployment in linux/amd64...'
	cd server && GOOS=linux GOARCH=amd64 go build -ldflags='-s -w' -o=./bin/linux_amd64/api ./cmd/api

## build/tools: build the cmd/tools applications for local machine and linux/amd64
.PHONY: build/tools
build/tools:
	@echo 'Building cmd/tools/makeadmin for local machine...'
	cd server && go build -ldflags='-s -w' -o=./bin/local/tools/makeadmin ./cmd/tools/makeadmin
	@echo 'Building cmd/tools/makeadmin for deployment in linux/amd64...'
	cd server && GOOS=linux GOARCH=amd64 go build -ldflags='-s -w' -o=./bin/linux_amd64/tools/makeadmin ./cmd/tools/makeadmin
	@echo 'Building cmd/tools/maketopics for local machine...'
	cd server && go build -ldflags='-s -w' -o=./bin/local/tools/maketopics ./cmd/tools/maketopics
	@echo 'Building cmd/tools/maketopics for deployment in linux/amd64...'
	cd server && GOOS=linux GOARCH=amd64 go build -ldflags='-s -w' -o=./bin/linux_amd64/tools/maketopics ./cmd/tools/maketopics
	@echo 'Building cmd/tools/createfeeds for local machine...'
	cd server && go build -ldflags='-s -w' -o=./bin/local/tools/createfeeds ./cmd/tools/createfeeds
	@echo 'Building cmd/tools/createfeeds for deployment in linux/amd64...'
	cd server && GOOS=linux GOARCH=amd64 go build -ldflags='-s -w' -o=./bin/linux_amd64/tools/createfeeds ./cmd/tools/createfeeds

# ==================================================================================== #
# PRODUCTION
# ==================================================================================== #

production_host_ip ?= ${PROD_IP}

## production/connect: connect to the production server
.PHONY: production/connect
production/connect:
	@if [ -z "${PROD_IP}" ]; then \
		echo "ERROR: PROD_IP is not set! Pass it like 'make production/connect PROD_IP=1.2.3.4' or set it as environment variable"; \
		exit 1; \
	fi
	ssh smphr@${production_host_ip}

## production/deploy/server: deploy the server to production
.PHONY: production/deploy/server
production/deploy/server:
	@if [ -z "${PROD_IP}" ]; then \
		echo "ERROR: PROD_IP is not set! Pass it like 'make production/deploy/api PROD_IP=1.2.3.4' or set it as environment variable"; \
		exit 1; \
	fi
	@echo 'Deploying api server on production...'
	rsync -P ./server/bin/linux_amd64/api smphr@${production_host_ip}:~
	rsync -rP --delete ./server/bin/linux_amd64/tools smphr@${production_host_ip}:~
	rsync -rP --delete ./server/migrations smphr@${production_host_ip}:~
	rsync -P ./server/remote/production/api.service smphr@${production_host_ip}:~
	rsync -P ./server/remote/production/Caddyfile smphr@${production_host_ip}:~
	ssh -t smphr@${production_host_ip} '\
		goose -dir ~/migrations postgres $${SMPHR_DSN} up \
		&& sudo mv ~/api.service /etc/systemd/system/ \
		&& sudo systemctl enable api \
		&& sudo systemctl restart api \
		&& sudo mv ~/Caddyfile /etc/caddy/ \
		&& sudo systemctl reload caddy \
	'
