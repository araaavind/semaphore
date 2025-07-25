# Semaphore

<div align="center">
  <img src="app/assets/icons/launcher_icon_dual.png" alt="Semaphore Logo" width="120" height="120">
  
  **A modern, feature-rich RSS reader with cross-platform support**
  
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
  [![Go Version](https://img.shields.io/badge/go-%3E%3D1.23.0-blue.svg)](https://golang.org/)
  [![Flutter Version](https://img.shields.io/badge/flutter-%3E%3D3.4.3-blue.svg)](https://flutter.dev/)
  
</div>

## 📖 Overview

Semaphore is a full-featured RSS reader application designed for modern content consumption. It consists of a cross-platform mobile application built with Flutter and a robust backend API server written in Go. The project emphasizes clean architecture, scalability, and user experience.

### ✨ Key Features

- **📱 Cross-platform mobile app** - Native iOS and Android applications built with Flutter
- **🔐 User authentication** - Secure email/username login with Google Sign-In integration
- **📰 RSS/Atom feed management** - Subscribe to and organize your favorite content sources
- **🎯 Topic-based organization** - Curated topics and categories for content discovery
- **📚 Content walls** - Create custom collections of feeds for focused reading
- **💾 Save articles** - Save articles for later
- **❤️ Social features** - Like and share articles
- **🔍 Advanced search** - Full-text search across feeds
- **📊 Analytics integration** - Firebase Analytics and Crashlytics support
- **🎨 Adaptive theming** - Light and dark mode support
- **📰 Popular sources** - Easily follow subreddits, medium publications, substacks, youtube channels etc.

## 🏗️ Architecture

Semaphore follows a clean architecture pattern with clear separation of concerns:

### Backend (Go)
```
server/
├── cmd/api/             # Application entry point and HTTP handlers
├── internal/
│   ├── data/            # Database models and queries
│   ├── cache/           # Redis caching layer
│   ├── mailer/          # Email service
│   └── validator/       # Input validation
├── migrations/          # Database schema migrations
└── vendor/              # Vendored dependencies
```

**Tech Stack:**
- **Language:** Go 1.23+
- **Database:** PostgreSQL with pgx driver
- **Cache:** Redis
- **HTTP Router:** httprouter
- **RSS Parsing:** gofeed
- **Migrations:** Goose

### Mobile App (Flutter)
```
app/lib/
├── features/           # Feature-based modules
│   ├── auth/           # Authentication
│   ├── feed/           # RSS feed management
│   ├── home/           # Main navigation
│   └── profile/        # User profile
├── core/               # Shared components
│   ├── router/         # Navigation (go_router)
│   ├── theme/          # UI theming
│   └── common/         # Shared widgets and utilities
└── packages/smphr_sdk/ # Custom SDK for Auth and request interceptors
```

**Tech Stack:**
- **Framework:** Flutter 3.4.3+
- **State Management:** flutter_bloc
- **Navigation:** go_router
- **HTTP Client:** dio
- **Local Storage:** Hive + shared_preferences
- **UI:** Material Design with adaptive theming

### SDK Package
The `smphr_sdk` provides a clean interface between the Flutter app and Go backend:
- **Authentication management** with automatic token refresh
- **Session persistence** across app restarts
- **Standardized error handling**
- **Network connectivity monitoring**

## 🚀 Getting Started

### Prerequisites

- **Go 1.23+** - [Install Go](https://golang.org/dl/)
- **Flutter 3.4.3+** - [Install Flutter](https://flutter.dev/docs/get-started/install)
- **PostgreSQL 15+** - [Install PostgreSQL](https://postgresql.org/download/)
- **Redis 7+** - [Install Redis](https://redis.io/download)
- **Docker & Docker Compose** (optional, for easier development setup)

### Environment Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/araaavind/semaphore.git
   cd semaphore
   ```

2. **Set up environment variables:**
   Create a `.envrc` file in the project root:
   ```bash
   export SEMAPHORE_DSN="postgres://username:password@localhost/semaphore?sslmode=disable"
   export SMTP_USERNAME="test-smtp-username"
   export SMTP_PASSWORD="test-smtp-password"
   export PROD_IP="production-server-ip"
   ```

### Quick Start with Docker

The easiest way to get started is using Docker Compose for the database services:

```bash
# Start PostgreSQL and Redis services
docker-compose up -d

# The services will be available at:
# - PostgreSQL: localhost:5432 (dev-db)
# - PostgreSQL Test: localhost:5433 (test-db)  
# - Redis: localhost:6379
```

### Backend Setup

1. **Navigate to the server directory:**
   ```bash
   cd server
   ```

2. **Install Go dependencies:**
   ```bash
   go mod download
   ```

3. **Set up the database:**
   ```bash
   # Install goose migration tool
   go install github.com/pressly/goose/v3/cmd/goose@latest
   
   # Run database migrations
   make db/migrations/up
   ```

4. **Start the API server:**
   ```bash
   make run/api
   ```

   The API server will be available at `http://localhost:4000`

### Mobile App Setup

1. **Navigate to the app directory:**
   ```bash
   cd app
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure Firebase (optional):**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
   - Update Firebase configuration in `lib/firebase_options.dart`

4. **Update server configuration:**
   ```dart
   // In lib/core/constants/server_constants.dart
   static const String baseUrl = 'http://localhost:4000/v1';
   ```

5. **Run the app:**
   ```bash
   # For development
   flutter run

   # Or build for specific platforms
   flutter build apk          # Android
   flutter build ios          # iOS
   ```

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details on:

- Setting up your development environment
- Code style and standards
- Submitting pull requests
- Reporting issues

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [gofeed](https://github.com/mmcdole/gofeed) - RSS/Atom parsing
- [pgx](https://github.com/jackc/pgx) - PostgreSQL driver
- [httprouter](https://github.com/julienschmidt/httprouter) - HTTP routing

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/semaphore/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/semaphore/discussions)

---
