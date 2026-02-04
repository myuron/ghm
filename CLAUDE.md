# CLAUDE.md

This file provides context for Claude Code when working on this project.

## Project Overview

**ghm** (GitHub Manager) is a TUI tool for managing GitHub Issues, built with Go and gocui.

See [SPECIFICATION.md](./SPECIFICATION.md) for the full specification.

## Quick Reference

### Technology Stack

- Language: Go 1.24
- TUI Framework: gocui
- GitHub API: go-gh library (uses gh CLI authentication)

### Commands

```bash
# Build
go build -o ghm ./cmd/ghm

# Run
./ghm

# Test
go test ./...

# Test with coverage
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out

# Lint
golangci-lint run

# Format
gofmt -w .
```

## Architecture

Layered architecture: UI → Domain ← Infrastructure

```
internal/
├── ui/           # TUI (gocui views, keybindings)
├── domain/       # Business logic, entities, interfaces
├── infra/        # GitHub API client (go-gh), config I/O
└── errors/       # Custom error types
```

## Coding Guidelines

1. **Follow Effective Go** and Go Code Review Comments
2. **TDD**: Write tests first (Red → Green → Refactor)
3. **Error handling**: Never ignore errors, wrap with context using `fmt.Errorf("...: %w", err)`
4. **Documentation**: All exported symbols must have comments starting with the symbol name
5. **Context**: Pass `context.Context` as first parameter for API calls

## Key Interfaces

```go
// internal/domain/interfaces/github_client.go
type GitHubClient interface {
    ListIssues(ctx context.Context, repo Repository, filter IssueFilter) ([]Issue, error)
    GetIssue(ctx context.Context, repo Repository, number int) (*Issue, error)
    // ... see SPECIFICATION.md for full interface
}

// internal/domain/interfaces/config_store.go
type ConfigStore interface {
    Load() (*Config, error)
    Save(config *Config) error
}
```

## Custom Error Types

- `NotFoundError` - Resource not found
- `AuthenticationError` - gh CLI authentication failed
- `PermissionError` - Insufficient permissions
- `NetworkError` - Network communication error
- `ValidationError` - Invalid input

## Testing Requirements

- Coverage target: 100% (in principle)
- Mock `GitHubClient` and `ConfigStore` for tests
- Test fixtures location: `internal/testutil/fixtures/`
