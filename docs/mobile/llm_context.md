# Mobile LLM Context - KlampisDepo

## Foundation

- **Language/Framework:** Dart / Flutter
- **Architecture:** Feature-First + Clean Architecture
- **State Management:** Riverpod (`flutter_riverpod`)
- **Base Dir:** `C:\project\klampisDepo\mobile`

## Core Architecture

- `lib/core/network`: Dio configuration, JWT interceptors, API endpoints.
- `lib/core/router`: GoRouter configuration with auth-based redirection.
- `lib/core/theme`: UI styling using `flex_color_scheme`.
- `lib/features/`: Domain-driven feature modules (Auth, Dashboard, Items, etc.).

## Components & Patterns

- **Auth Notifier:** Manages login/logout state and token persistence via `shared_preferences`.
- **Navigation:** Side drawer for navigation between POS modules.
- **Error Handling:** Centralized Dio interceptor for `401` errors and failed API calls.

## Networking

- Default API Base URL: `http://10.0.2.2:8080/api/v1` (Android Emulator) or local IP.
- Uses `Authorization: Bearer <token>` in headers.

## Development Workflows

- `flutter create .`: Required to generate platform folders (android/ios).
- `flutter pub get`: Installs dependencies from `pubspec.yaml`.
- The app follows a strictly decoupled structure where UI (Presentation) never touches Data layers directly; always via Providers.
