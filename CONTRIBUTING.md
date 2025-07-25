# Contributing to Semaphore

Thank you for your interest in contributing to Semaphore! We welcome contributions of all kinds, from bug reports and feature requests to code improvements and documentation updates.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Making Changes](#making-changes)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Review Process](#review-process)
- [Community](#community)

## 🤝 Code of Conduct

This project adheres to a code of conduct that we expect all contributors to follow. Please be respectful, inclusive, and professional in all interactions.

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Go 1.23+** - [Installation Guide](https://golang.org/dl/)
- **Flutter 3.4.3+** - [Installation Guide](https://flutter.dev/docs/get-started/install)
- **PostgreSQL 15+** - [Installation Guide](https://postgresql.org/download/)
- **Redis 7+** - [Installation Guide](https://redis.io/download)
- **Docker & Docker Compose** - [Installation Guide](https://docs.docker.com/get-docker/)
- **Git** - [Installation Guide](https://git-scm.com/downloads)

### Development Tools

**Required:**
- `goose` - Database migration tool: `go install github.com/pressly/goose/v3/cmd/goose@latest`

**Recommended:**
- **VS Code** with Go and Flutter extensions
- **Android Studio** for Android development
- **Xcode** for iOS development (macOS only)

## 🛠️ Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/semaphore.git
cd semaphore

# Add upstream remote
git remote add upstream https://github.com/araaavind/semaphore.git
```

### 2. Environment Configuration

Create a `.envrc` file in the project root:

```bash
# Database configuration
export SEMAPHORE_DSN="postgres://semaphore:password@localhost/semaphore?sslmode=disable"

# Email configuration (for development, you can use a test service like MailHog)
export SMTP_USERNAME="your-smtp-username"
export SMTP_PASSWORD="your-smtp-password"

# Optional: Production server IP (only needed for deployment)
export PROD_IP="your-production-server-ip"

# Optional: Google API configuration
export GOOGLE_CLIENT_ID="your-google-client-id"
export YOUTUBE_API_KEY="your-youtube-api-key"
```

### 3. Database Setup

**Option A: Using Docker (Recommended for development)**

```bash
# Start PostgreSQL and Redis containers
docker-compose up -d

# Run migrations
make db/migrations/up
```

**Option B: Local Installation**

```bash
# Create database
createdb semaphore

# Install citext extension
psql -d semaphore -c "CREATE EXTENSION IF NOT EXISTS citext;"

# Run migrations
make db/migrations/up
```

### 4. Backend Setup

```bash
cd server

# Download dependencies
go mod download

# Verify setup
make audit

# Start the server
make run/api
```

The API server will be available at `http://localhost:4000`

### 5. Mobile App Setup

```bash
cd app

# Install Flutter dependencies
flutter pub get

# Verify Flutter setup
flutter doctor

# Update server URL for development
# Edit lib/core/constants/server_constants.dart
# Change baseUrl to 'http://localhost:4000/v1'

# Run the app
flutter run
```

## 📁 Project Structure

Understanding the project structure will help you navigate and contribute effectively:

### Backend Structure (`server/`)

```
server/
├── cmd/
│   ├── api/                # Main API application
│   │   ├── main.go         # Application entry point
│   │   ├── routes.go       # HTTP route definitions
│   │   ├── middleware.go   # HTTP middleware
│   │   └── [feature].go    # Feature-specific handlers
│   └── tools/              # Administrative tools
│       ├── createfeeds/    # Feed creation utility
│       ├── makeadmin/      # Admin user creation
│       └── maketopics/     # Topic creation utility
├── internal/               # Private application code
│   ├── data/               # Database models and queries
│   ├── cache/              # Redis caching layer
│   ├── mailer/             # Email functionality
│   ├── validator/          # Input validation
│   └── vcs/                # Version control info
├── migrations/             # Database migration files
├── public/                 # Static assets and HTML templates
└── vendor/                 # Vendored Go dependencies
```

### Frontend Structure (`app/`)

```
app/
├── lib/
│   ├── features/             # Feature-based modules
│   │   ├── auth/             # Authentication feature
│   │   │   ├── data/         # Data layer (repositories, data sources)
│   │   │   ├── domain/       # Business logic (entities, use cases)
│   │   │   └── presentation/ # UI layer (pages, widgets, state)
│   │   ├── feed/             # RSS feed, walls management
│   │   ├── home/             # Main navigation
│   │   └── profile/          # User profile management
│   ├── core/                 # Shared application components
│   │   ├── common/           # Shared widgets and utilities
│   │   ├── constants/        # Application constants
│   │   ├── errors/           # Error handling
│   │   ├── router/           # Navigation configuration
│   │   ├── services/         # Core services
│   │   ├── theme/            # UI theming
│   │   └── utils/            # Utility functions
│   └── packages/smphr_sdk/   # Custom API client SDK
├── assets/                   # Static assets (images, fonts)
├── android/                  # Android-specific configuration
└── ios/                      # iOS-specific configuration
```

## 📏 Coding Standards

### Go Code Style

We follow standard Go conventions with some additional guidelines:

**Formatting:**
```bash
# Format code
go fmt ./...

# Vet code
go vet ./...

# Static analysis
staticcheck ./...
```

**Key Principles:**
- The go server architecture is inspired from the book Let's go further by Alex Edwards.
- Use meaningful variable and function names
- Keep functions small and focused
- Handle errors explicitly
- Use context.Context for cancellation and timeouts

**Example:**
```go
// Good
func (m UserModel) GetByEmail(email string) (*User, error) {
    query := `SELECT id, email, username FROM users WHERE email = $1`
    
    ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
    defer cancel()
    
    var user User
    err := m.DB.QueryRow(ctx, query, email).Scan(&user.ID, &user.Email, &user.Username)
    if err != nil {
        switch {
        case errors.Is(err, pgx.ErrNoRows):
            return nil, ErrRecordNotFound
        default:
            return nil, err
        }
    }
    
    return &user, nil
}
```

### Flutter/Dart Code Style

We follow the [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) with these additions:

**Formatting:**
```bash
# Format code
dart format .

# Analyze code
flutter analyze
```

**Architecture Principles:**
- Follow Clean Architecture patterns
- Use BLoC pattern for state management
- Separate concerns clearly (data, domain, presentation)
- Write widget tests for UI components
- Use meaningful names for classes and methods

**Example:**
```dart
// Good: Clean separation of concerns
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  
  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AuthInitial()) {
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }
  
  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    try {
      final result = await _authRepository.signIn(
        email: event.email,
        password: event.password,
      );
      
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }
}
```

## 🔧 Making Changes

### Branching Strategy

We use a feature branch workflow:

```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description

# Make your changes and commit
git add .
git commit -m "feat: add user authentication"

# Push to your fork
git push origin feature/your-feature-name
```

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

```
[optional scope(app/server/sdk)] <type>: <short description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
app feat: add Google Sign-In integration
server fix: resolve duplicate feed entries
server docs: update installation instructions
sdk refactor: improve error handling middleware
```

### Database Migrations

When making database changes:

```bash
# Create a new migration
make db/migrations/new name=add_user_preferences

# Edit the generated migration file in server/migrations/
# Always include both up and down migrations

# Test the migration
make db/migrations/up
make db/migrations/down
```

### Adding New Features

When adding new features, follow these steps:

1. **Plan the feature**: Create an issue describing the feature
2. **Design the API**: Plan database changes and API endpoints
3. **Backend implementation**: Start with data models, then business logic, then HTTP handlers
4. **Frontend implementation**: Follow clean architecture (data → domain → presentation)
5. **Testing**: Write comprehensive tests
6. **Documentation**: Update relevant documentation

## 📥 Submitting Changes

### Pull Request Process

1. **Ensure your branch is up to date:**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run all tests and linting:**
   ```bash
   # Backend
   cd server && make audit
   
   # Frontend
   cd app && flutter analyze && flutter test
   ```

3. **Create a pull request:**
   - Use a descriptive title following conventional commit format
   - Fill out the pull request template completely
   - Link any related issues
   - Add screenshots for UI changes
   - Ensure CI passes

### Pull Request Template

```markdown
## Description
Brief description of the changes and the problem they solve.

## Type of Change
- [ ] Bug fix (non-breaking change that fixes an issue)
- [ ] New feature (non-breaking change that adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
Describe the tests you ran and provide instructions to reproduce.

## Screenshots (if applicable)
Add screenshots to help explain your changes.

## Checklist
- [ ] My code follows the project's style guidelines
- [ ] I have performed a self-review of my code
- [ ] I have commented my code, particularly in hard-to-understand areas
- [ ] I have made corresponding changes to the documentation
- [ ] My changes generate no new warnings
- [ ] I have added tests that prove my fix is effective or that my feature works
- [ ] New and existing unit tests pass locally with my changes
```

## 👀 Review Process

### What to Expect

1. **Automated Checks**: CI will run tests and linting
2. **Code Review**: Maintainers will review your code
3. **Feedback**: You may receive suggestions for improvements
4. **Approval**: Once approved, your PR will be merged

### Review Criteria

- **Functionality**: Does the code work as intended?
- **Code Quality**: Is the code readable and well-structured?
- **Testing**: Are there adequate tests?
- **Documentation**: Is documentation updated if needed?
- **Performance**: Does the change impact performance?
- **Security**: Are there any security concerns?

## 🎯 Types of Contributions

### 🐛 Bug Reports

When reporting bugs, please include:

- **Environment**: OS, Go version, Flutter version
- **Steps to reproduce**: Clear steps to reproduce the issue
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Screenshots**: If applicable
- **Logs**: Relevant log output

### ✨ Feature Requests

For feature requests, please include:

- **Problem**: What problem does this solve?
- **Solution**: Describe your proposed solution
- **Alternatives**: What alternatives have you considered?
- **Use cases**: Who would benefit from this feature?

### 📚 Documentation

Documentation improvements are always welcome:

- Fix typos or unclear explanations
- Add examples or tutorials
- Improve API documentation
- Update setup instructions

### 🧪 Testing

Help improve test coverage:

- Add unit tests for untested code
- Write integration tests
- Improve test reliability
- Add performance tests

## 🌟 Recognition

Contributors will be recognized in:

- The project's README
- Release notes
- Annual contributor highlights

## 💬 Community

### Getting Help

- **GitHub Discussions**: For questions and general discussion
- **GitHub Issues**: For bug reports and feature requests
- **Code Reviews**: Learn from feedback on pull requests

### Communication Guidelines

- Be respectful and inclusive
- Provide constructive feedback
- Help newcomers get started
- Share knowledge and resources

## 🏷️ Good First Issues

Look for issues labeled `good first issue` or `help wanted`. These are specifically chosen to be newcomer-friendly.

## 📚 Additional Resources

- [Go Documentation](https://golang.org/doc/)
- [Go Architecture](https://lets-go-further.alexedwards.net/)
- [Flutter Documentation](https://flutter.dev/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [BLoC Pattern](https://bloclibrary.dev/)

---

Thank you for contributing to Semaphore! Your efforts help make this project better for everyone. 🎉 