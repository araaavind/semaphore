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
	cd server && go run ./cmd/api -dsn=${SEMAPHORE_DSN}

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
