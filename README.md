# Go Backend Template

Template for Go backends using:

- DDD (rich domain model)
- CQRS-lite (read/write path separation)
- Anti-Corruption Layer (external contract isolation)

`agents.md` is the architectural source of truth for contributors and AI agents. This README is a practical, developer-focused guide aligned with those rules.

## Architecture Principles

- Keep business rules and invariants in `internal/model`.
- Keep application orchestration in `internal/service`.
- Keep transport concerns (HTTP/gRPC/consumer DTOs and mapping) in `internal/handler`.
- Keep persistence concerns in `internal/repository` with explicit storage-to-domain/query mapping.
- Keep external vendor contracts inside `internal/integration` adapters only.
- Keep dependencies flowing downward only:
	- `cmd -> handler -> service -> model`
	- `service -> repository` (via ports/interfaces)
	- `service -> integration` (via ports/interfaces)
	- `handler -> read_repository` is allowed for CQRS-lite reads

## Project Layout

```text
.
|- cmd/                     # app entry points, wiring, startup only
|- db/
|  |- migrations/           # SQL migrations
|  `- schema.sql            # schema snapshot/base schema
|- internal/
|  |- config/               # config model, load, validation
|  |- di/                   # dependency injection container
|  |- errors/               # shared sentinel errors
|  |- handler/              # transport layer
|  |- integration/          # ACL for external systems
|  |- model/                # domain entities, value objects, invariants
|  |- repository/           # storage implementations
|  `- service/              # use-case orchestration
|- logs/                    # runtime logs (local/dev)
|- Taskfile.yaml            # format/lint/test/migration tasks
`- Makefile                 # build/run helpers
```

## Prerequisites

- Development is supported on Unix-like systems only (Linux, macOS, BSD).
- Go `1.25.0` (see `go.mod`)
- `task` CLI (https://taskfile.dev)
- `make`

## Quick Start

1. Clone the repository.
2. Adjust `config.yaml` if needed.
3. Run the app:

```bash
make run
```

Equivalent command:

```bash
go run ./cmd/main.go
```

You can pass a custom config path:

```bash
go run ./cmd/main.go -config ./config.yaml
```

## Configuration

Current config root is:

- `logger`

Config loading behavior:

- Reads YAML from a path provided via CLI flag (`-config`).
- Expands environment templates using `os.ExpandEnv` (`$VAR` or `${VAR}`).
- Validates the resulting struct using `go-playground/validator`.

Important note:

- Missing environment variables are expanded to an empty string by `os.ExpandEnv`.
- Any critical settings should be validated as required in config validation tags.

## Development Commands

Quality and tooling commands are defined in `Taskfile.yaml`.

```bash
task format       # gofumpt + gci
task lint         # golangci-lint
task test         # go test ./...
task vuln         # govulncheck
task generate     # go generate ./...
```

Build and run commands are in `Makefile`.

```bash
make build
make build-all
make run
make clean
```

## Database Migrations

Set `DATABASE_URL` in Go DSN format before running migration commands.

PostgreSQL example:

```bash
export DATABASE_URL='postgres://user:password@localhost:5432/dbname?sslmode=disable'
```

Migration workflow:

```bash
task migration-new -- add_orders_table
task migration-up
task migration-down
```

Migration quality requirements:

- Each migration must include both `-- migrate:up` and `-- migrate:down`.
- `down` must be meaningfully reversible.
- Validate apply and rollback before merge.

## Module Rename Helper

If you are bootstrapping a new project from this template, `setup.sh` can replace the module path safely with a dry-run + confirmation workflow.