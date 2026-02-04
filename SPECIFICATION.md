# ghm - GitHub Manager Specification

## 1. Overview

### 1.1 Project Name

**ghm** - GitHub Manager

### 1.2 Summary

A terminal-based TUI tool for managing GitHub Issues.

### 1.3 Background

The GitHub CLI (`gh`) is a powerful command-line tool, but it lacks an interactive TUI mode. Issue management is a frequent task for developers, and having to repeatedly type commands or switch to a browser interrupts workflow. ghm addresses this gap by providing an interactive TUI for Issue management without leaving the terminal.

### 1.4 Goals

- Manage GitHub Issues without leaving the terminal
- Support the full Issue lifecycle (open to close) within a single interface
- Enable switching between multiple repositories seamlessly

### 1.5 Scope

**MVP (Minimum Viable Product):**
- Issue lifecycle management: view, create, comment, label, assign, close, and reopen Issues

**Future:**
- Pull Request management
- Expand to cover all `gh` CLI functionality in TUI form

### 1.6 Technology Stack

| Component | Technology |
|-----------|------------|
| Language | Go 1.24 |
| TUI Framework | gocui |
| GitHub API | go-gh library (uses gh CLI authentication) |

### 1.7 Quality

This project follows Test-Driven Development (TDD) to ensure high code quality and maintainability.

## 2. Functional Requirements

### 2.1 Issue List

| ID | Requirement | Description |
|----|-------------|-------------|
| F-LIST-01 | Display Issue list | Display a list of Issues in the specified repository |
| F-LIST-02 | Filter by status | Filter Issues by status: open / closed / all |
| F-LIST-03 | Sort | Sort Issues by: created date, updated date, comment count, etc. |
| F-LIST-04 | Pagination | Support pagination or infinite scroll for large Issue lists |

### 2.2 Issue Creation

| ID | Requirement | Description |
|----|-------------|-------------|
| F-CREATE-01 | Create Issue | Create a new Issue with title and body |
| F-CREATE-02 | Auto-refresh | Automatically refresh the Issue list after creation |

### 2.3 Issue Detail View

| ID | Requirement | Description |
|----|-------------|-------------|
| F-VIEW-01 | Display Issue details | Show title, body, status, labels, and assignees |
| F-VIEW-02 | Display comments | Show the list of comments on the Issue |
| F-VIEW-03 | Display metadata | Show author, created date, and updated date |

### 2.4 Comments

| ID | Requirement | Description |
|----|-------------|-------------|
| F-COMMENT-01 | Add comment | Add a new comment to an Issue |
| F-COMMENT-02 | Edit comment | Edit an existing comment |
| F-COMMENT-03 | Delete comment | Delete a comment |

### 2.5 Labels

| ID | Requirement | Description |
|----|-------------|-------------|
| F-LABEL-01 | Add label | Add a label to an Issue |
| F-LABEL-02 | Remove label | Remove a label from an Issue |

### 2.6 Assignees

| ID | Requirement | Description |
|----|-------------|-------------|
| F-ASSIGN-01 | Assign user | Assign a user to an Issue (including users other than self) |
| F-ASSIGN-02 | Unassign user | Remove an assignee from an Issue |

### 2.7 Issue Status

| ID | Requirement | Description |
|----|-------------|-------------|
| F-STATUS-01 | Close Issue | Close an open Issue |
| F-STATUS-02 | Reopen Issue | Reopen a closed Issue |

### 2.8 Repository Switching

| ID | Requirement | Description |
|----|-------------|-------------|
| F-REPO-01 | Switch repository | Switch to any repository by specifying owner/repo |
| F-REPO-02 | Recent repositories | Display history of recently used repositories |

## 3. UI Design

### 3.1 Layout

```
+----------------------------------------------------------+
|  Header: owner/repo                                      |
+-------------------+--------------------------------------+
|                   |                                      |
|  [1] Issue List   |  [2] Issue Detail                    |
|                   |                                      |
|  #123 Bug report  |  Title: Bug report                   |
|  #122 Feature req |  Status: open                        |
|  #121 Question    |  Labels: bug, urgent                 |
|                   |  Assignees: @user1                   |
|                   |                                      |
|                   |  Body:                               |
|                   |  Lorem ipsum dolor sit amet...       |
|                   |                                      |
|                   |  Comments (3):                       |
|                   |  ...                                 |
|                   |                                      |
+-------------------+--------------------------------------+
|  Footer: [c]reate [C]omment [L]abel [A]ssign [x]close    |
+----------------------------------------------------------+
```

| Component | Description |
|-----------|-------------|
| Header | Display current repository (owner/repo format) |
| Panel 1 (Left) | Issue list with number, title, and status indicators |
| Panel 2 (Right) | Issue detail view including body and comments |
| Footer | Display available keybindings as hints |
| Focus indicator | Highlighted border or color change for active panel |

### 3.2 Screens

| Screen | Description |
|--------|-------------|
| Main | Issue list + detail panel (default view) |
| Repository selector | Recent repositories + input field for new repository |
| Label selector | List of available labels with toggle selection |
| Assignee selector | List of repository collaborators |
| Confirmation dialog | Modal for destructive actions (delete, close) |

### 3.3 Keybindings

#### Navigation

| Key | Action |
|-----|--------|
| `j` / `k` | Move down / up in list |
| `h` / `l` | Scroll left / right (in detail view) |
| `1` | Focus Panel 1 (Issue list) |
| `2` | Focus Panel 2 (Issue detail) |
| `g` | Go to top of list |
| `G` | Go to bottom of list |

#### Actions

| Key | Action |
|-----|--------|
| `c` | Create new Issue |
| `C` | Add comment |
| `L` | Open label selector |
| `A` | Open assignee selector |
| `x` | Close / Reopen Issue |
| `e` | Edit comment (in comment view) |
| `d` | Delete comment (in comment view) |

#### Global

| Key | Action |
|-----|--------|
| `f` | Toggle filter (open / closed / all) |
| `s` | Change sort order |
| `R` | Switch repository |
| `?` | Show help |
| `q` | Quit application |
| `Esc` | Close dialog / Cancel operation |

### 3.4 Input Method

| Item | Method |
|------|--------|
| Issue title | External editor ($EDITOR) |
| Issue body | External editor ($EDITOR) |
| Comment | External editor ($EDITOR) |
| Editor execution | Overlay within TUI (does not leave the terminal) |

### 3.5 Feedback

| Type | Display Method |
|------|----------------|
| Error | Popup dialog with error message |
| Success | Temporary message in status bar |
| Loading | Spinner or loading message in status bar |

## 4. Technical Design

### 4.1 Architecture

The application follows a layered architecture with three main layers:

```
+------------------+
|       UI         |  gocui views, keybindings, rendering
+------------------+
         |
         v
+------------------+
|     Domain       |  Business logic, entities, interfaces
+------------------+
         ^
         |
+------------------+
|   Infrastructure |  GitHub API (go-gh), config file I/O
+------------------+
```

**Dependency Direction:**
- UI depends on Domain
- Infrastructure depends on Domain
- Domain has no external dependencies (pure business logic)

**Dependency Inversion:**
- Domain defines interfaces (e.g., `GitHubClient`, `ConfigStore`)
- Infrastructure implements these interfaces
- UI receives implementations via dependency injection

### 4.2 Package Structure

```
ghm/
├── cmd/
│   └── ghm/
│       └── main.go           # Entry point
├── internal/
│   ├── ui/
│   │   ├── app.go            # Application lifecycle
│   │   ├── views/            # gocui view components
│   │   │   ├── issue_list.go
│   │   │   ├── issue_detail.go
│   │   │   ├── dialog.go
│   │   │   └── ...
│   │   └── keybindings.go    # Key binding definitions
│   ├── domain/
│   │   ├── entities/         # Domain entities
│   │   │   ├── issue.go
│   │   │   ├── comment.go
│   │   │   ├── label.go
│   │   │   ├── user.go
│   │   │   └── repository.go
│   │   ├── services/         # Business logic
│   │   │   └── issue_service.go
│   │   └── interfaces/       # Interface definitions
│   │       ├── github_client.go
│   │       └── config_store.go
│   ├── infra/
│   │   ├── github/           # GitHub API client (go-gh)
│   │   │   └── client.go
│   │   └── config/           # Config file operations
│   │       └── store.go
│   └── errors/               # Custom error types
│       └── errors.go
├── go.mod
├── go.sum
└── README.md
```

### 4.3 Entities

#### Issue

| Field | Type | Description |
|-------|------|-------------|
| ID | int64 | GitHub Issue ID |
| Number | int | Issue number (e.g., #123) |
| Title | string | Issue title |
| Body | string | Issue body (Markdown) |
| State | string | "open" or "closed" |
| Labels | []Label | Attached labels |
| Assignees | []User | Assigned users |
| Comments | []Comment | Issue comments |
| Author | User | Issue creator |
| CreatedAt | time.Time | Creation timestamp |
| UpdatedAt | time.Time | Last update timestamp |

#### Comment

| Field | Type | Description |
|-------|------|-------------|
| ID | int64 | Comment ID |
| Body | string | Comment body (Markdown) |
| Author | User | Comment author |
| CreatedAt | time.Time | Creation timestamp |
| UpdatedAt | time.Time | Last update timestamp |

#### Label

| Field | Type | Description |
|-------|------|-------------|
| ID | int64 | Label ID |
| Name | string | Label name |
| Color | string | Hex color code (e.g., "ff0000") |

#### User

| Field | Type | Description |
|-------|------|-------------|
| Login | string | GitHub username |
| Name | string | Display name |

#### Repository

| Field | Type | Description |
|-------|------|-------------|
| Owner | string | Repository owner (user or org) |
| Name | string | Repository name |

### 4.4 Interfaces

#### GitHubClient

```go
type GitHubClient interface {
    // Issue operations
    ListIssues(ctx context.Context, repo Repository, filter IssueFilter) ([]Issue, error)
    GetIssue(ctx context.Context, repo Repository, number int) (*Issue, error)
    CreateIssue(ctx context.Context, repo Repository, title, body string) (*Issue, error)
    CloseIssue(ctx context.Context, repo Repository, number int) error
    ReopenIssue(ctx context.Context, repo Repository, number int) error

    // Comment operations
    ListComments(ctx context.Context, repo Repository, issueNumber int) ([]Comment, error)
    AddComment(ctx context.Context, repo Repository, issueNumber int, body string) (*Comment, error)
    EditComment(ctx context.Context, repo Repository, commentID int64, body string) (*Comment, error)
    DeleteComment(ctx context.Context, repo Repository, commentID int64) error

    // Label operations
    ListLabels(ctx context.Context, repo Repository) ([]Label, error)
    AddLabels(ctx context.Context, repo Repository, issueNumber int, labels []string) error
    RemoveLabel(ctx context.Context, repo Repository, issueNumber int, label string) error

    // Assignee operations
    ListCollaborators(ctx context.Context, repo Repository) ([]User, error)
    AddAssignees(ctx context.Context, repo Repository, issueNumber int, assignees []string) error
    RemoveAssignee(ctx context.Context, repo Repository, issueNumber int, assignee string) error
}
```

#### ConfigStore

```go
type ConfigStore interface {
    Load() (*Config, error)
    Save(config *Config) error
}
```

### 4.5 Configuration

**Location:** `~/.config/ghm/config.json`

**Structure:**

```json
{
  "recent_repositories": [
    "owner1/repo1",
    "owner2/repo2"
  ],
  "default_filter": "open",
  "default_sort": "updated",
  "max_recent_repositories": 10
}
```

### 4.6 Custom Error Types

| Error Type | Description | Example Scenario |
|------------|-------------|------------------|
| `NotFoundError` | Resource not found | Issue #999 does not exist |
| `AuthenticationError` | Authentication failed | gh CLI not authenticated |
| `PermissionError` | Insufficient permissions | Cannot close Issue in read-only repo |
| `NetworkError` | Network communication error | GitHub API unreachable |
| `ValidationError` | Invalid input | Empty Issue title |

**Usage Example:**

```go
issue, err := client.GetIssue(repo, 999)
if err != nil {
    var notFound *errors.NotFoundError
    if errors.As(err, &notFound) {
        // Show "Issue not found" message
    }
    // Handle other errors
}
```

## 5. Security

### 5.1 Authentication

| Item | Policy |
|------|--------|
| Token handling | Reuse gh CLI authentication via go-gh library |
| Token storage | Never handle or store tokens directly |
| Auth failure | Display message prompting user to re-authenticate with gh CLI |
| gh CLI not installed | Display error message and exit; gh CLI is a prerequisite |

### 5.2 Input Handling

| Item | Policy |
|------|--------|
| Input validation | Delegate to GitHub API (no app-side restrictions) |
| Markdown injection | Handled by GitHub's rendering layer |

### 5.3 External Editor

| Item | Policy |
|------|--------|
| $EDITOR execution | User's responsibility (user controls their environment) |
| Temporary files | Create in secure location, delete after use |

### 5.4 Configuration File

| Item | Policy |
|------|--------|
| Sensitive data | Never store tokens or credentials in config.json |
| Stored content | Repository history only (no authentication data) |

### 5.5 Logging and Output

| Item | Policy |
|------|--------|
| Tokens | Never output in logs or error messages |
| Private repository names | Minimize exposure in error messages |
| Debug mode | Mask authentication information even in verbose output |

## 6. Testing

### 6.1 Test-Driven Development (TDD)

All development must follow the TDD cycle:

```
+-------+     +-------+     +----------+
|  Red  | --> | Green | --> | Refactor |
+-------+     +-------+     +----------+
    ^                            |
    |                            |
    +----------------------------+
```

| Phase | Description |
|-------|-------------|
| Red | Write a failing test first |
| Green | Write minimal code to make the test pass |
| Refactor | Improve code quality while keeping tests green |

**Rules:**
- New features must start with a test
- Bug fixes must start with a test that reproduces the bug
- No production code without a corresponding test

### 6.2 Test Types

| Type | Scope | Description |
|------|-------|-------------|
| Unit | Function/Method | Test individual functions and methods in isolation |
| Integration | Component | Test interaction between multiple components |
| E2E | Application | Test the entire TUI workflow from user perspective |

### 6.3 Test Targets by Layer

| Layer | Test Focus |
|-------|------------|
| Domain | Business logic, entity validation, service methods |
| Infrastructure | GitHub API client (with mocks), config file operations |
| UI | Keybinding handlers, view rendering, user interactions |
| Errors | Error type creation, error handling paths |

### 6.4 Mocking Strategy

**Required Mocks:**

| Interface | Mock Purpose |
|-----------|--------------|
| `GitHubClient` | Simulate GitHub API responses without network calls |
| `ConfigStore` | Simulate config file operations without filesystem access |

**Test Fixtures:**

Provide sample data for testing:
- Sample Issues (open, closed, with labels, with assignees)
- Sample Comments
- Sample Labels
- Sample Users
- Sample Repositories

**Location:** `internal/testutil/fixtures/`

### 6.5 Coverage

| Item | Target |
|------|--------|
| Coverage goal | 100% (in principle) |
| Coverage report | Generate with `go test -coverprofile` |
| PR policy | Block PRs that decrease coverage |

**Exceptions:**
- Main entry point (`cmd/ghm/main.go`) may have lower coverage
- Platform-specific code that cannot be tested in CI

### 6.6 CI/CD

**GitHub Actions Workflow:**

| Trigger | Actions |
|---------|---------|
| Pull Request | Run all tests, generate coverage report, post coverage comment |
| Push to main | Run all tests, block merge if tests fail |

**Pipeline Steps:**

```yaml
1. Checkout code
2. Setup Go 1.24
3. Install dependencies
4. Run linter (golangci-lint)
5. Run unit tests with coverage
6. Run integration tests
7. Run E2E tests
8. Generate coverage report
9. Post coverage to PR comment
10. Fail if coverage decreased
```

**Branch Protection:**
- Require tests to pass before merge
- Require coverage check to pass before merge

## 7. Coding Guidelines

### 7.1 Reference Guidelines

All code must comply with the following guidelines:

| Guideline | URL | Priority |
|-----------|-----|----------|
| Effective Go | https://go.dev/doc/effective_go | Required |
| Go Code Review Comments | https://go.dev/wiki/CodeReviewComments | Required |

### 7.2 Formatting

| Item | Rule |
|------|------|
| Formatter | All code must be formatted with `gofmt` |
| CI check | Formatting is verified in CI; unformatted code blocks merge |

### 7.3 Documentation

| Item | Rule |
|------|------|
| Exported symbols | All exported functions, types, and constants must have comments |
| Comment format | Comments must start with the name of the symbol (e.g., `// ListIssues returns...`) |
| Docstring coverage | Minimum 80% coverage required |
| Code review | CodeRabbit enforces documentation requirements |

**Example:**

```go
// Issue represents a GitHub issue with its metadata and comments.
type Issue struct {
    // ...
}

// ListIssues returns all issues in the repository matching the given filter.
// It returns an error if the repository is not accessible.
func (c *Client) ListIssues(repo Repository, filter IssueFilter) ([]Issue, error) {
    // ...
}
```

### 7.4 Error Handling

| Item | Rule |
|------|------|
| Error checking | All errors must be handled; never ignore errors |
| Error wrapping | Wrap errors with context using `fmt.Errorf("...: %w", err)` |

**Example:**

```go
// Good
issues, err := client.ListIssues(repo, filter)
if err != nil {
    return nil, fmt.Errorf("failed to list issues for %s/%s: %w", repo.Owner, repo.Name, err)
}

// Bad - error ignored
issues, _ := client.ListIssues(repo, filter)
```

### 7.5 Package Design

| Item | Rule |
|------|------|
| Circular dependencies | Avoid circular imports between packages |
| Internal packages | Use `internal/` to restrict package visibility |
| Package cohesion | Each package should have a single, clear responsibility |

### 7.6 General Practices

| Item | Rule |
|------|------|
| Global variables | Avoid global variables; use dependency injection |
| init() functions | Minimize use of `init()`; prefer explicit initialization |
| context.Context | Pass `context.Context` as first parameter for API calls |

**Example:**

```go
// Good - context as first parameter
func (c *Client) GetIssue(ctx context.Context, repo Repository, number int) (*Issue, error) {
    // ...
}

// Bad - no context
func (c *Client) GetIssue(repo Repository, number int) (*Issue, error) {
    // ...
}
```

## 8. Future Enhancements

The following features are planned for post-MVP releases.

### 8.1 Pull Request Management

| ID | Feature | Description |
|----|---------|-------------|
| F-PR-01 | List PRs | Display PR list with filter and sort support |
| F-PR-02 | View PR details | Show diff, commits, and review comments |
| F-PR-03 | Create PR | Create a new Pull Request |
| F-PR-04 | Merge PR | Merge with method selection (merge / squash / rebase) |
| F-PR-05 | Close / Reopen PR | Close or reopen a Pull Request |
| F-PR-06 | Request review | Request review from collaborators |
| F-PR-07 | Submit review | Approve / Request changes / Comment |
| F-PR-08 | Comment on PR | Add comments to Pull Request |

### 8.2 Additional Issue Features

| ID | Feature | Description |
|----|---------|-------------|
| F-ISSUE-01 | Milestones | Set and change milestones on Issues |
| F-ISSUE-02 | Projects | Add Issues to GitHub Projects, move between columns |
| F-ISSUE-03 | Templates | Support Issue templates when creating new Issues |
| F-ISSUE-04 | Search | Search Issues by title, body, labels, etc. |

### 8.3 Other Enhancements

| ID | Feature | Description |
|----|---------|-------------|
| F-OTHER-01 | Custom keybindings | Allow users to customize keybindings |
| F-OTHER-02 | Themes | Support custom themes and color schemes |
| F-OTHER-03 | Multiple accounts | Support multiple accounts (GitHub.com and GitHub Enterprise) |
