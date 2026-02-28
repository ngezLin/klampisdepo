# KlampisDepo Mobile App Proposal (Flutter)

This document outlines the proposed architecture, folder structure, best practices, and tech stack for building the KlampisDepo mobile application using Flutter from scratch. The app will communicate with the existing backend at `C:\project\klampisDepo\api`.

## 1. Architectural Approach

For a point-of-sale (POS) and inventory management system that will scale in complexity, a **Feature-First (Domain-Driven) Architecture** combined with **Clean Architecture** principles is recommended.

### Why Feature-First?

Instead of grouping files by type (e.g., all controllers together, all views together), files are grouped by the feature they belong to. This makes it much easier to scale the team, find related files, and eventually extract features into separate packages if needed.

## 2. Tech Stack & Key Packages

- **State Management:** `flutter_riverpod` (Modern, compile-safe, and highly scalable for POS state). Alternatively, `flutter_bloc` is a solid choice if you prefer strict event-driven state constraints.
- **Routing:** `go_router` (Declarative routing, great for deep linking and auth guards).
- **Networking:** `dio` + `retrofit` (For robust API requests, interceptors, and typed responses out of the box).
- **Local Storage / Caching:** `shared_preferences` (for tokens) and `isar` or `sqflite` (if offline capabilities are needed for POS transactions during unstable connections).
- **UI/Theming:** `flex_color_scheme` (for beautiful and consistent light/dark theming out of the box).
- **Functional Programming / Error Handling:** `fpdart` or `dartz` (to use `Either` types for clean error handling from the API).

---

## 3. Proposed Folder Structure

```text
lib/
│
├── core/                         # Shared application-wide utilities (Independent of features)
│   ├── constants/                # App-wide constants (colors, dimensions, strings)
│   ├── network/                  # Dio clients, API interceptors, endpoints
│   ├── router/                   # go_router configuration and route definitions
│   ├── theme/                    # ThemeData definitions (light/dark mode)
│   ├── utils/                    # Helper functions (date formatters, currency formatters)
│   ├── widgets/                  # Reusable UI components (CustomButton, CustomTextField)
│   └── errors/                   # Custom exceptions and failures
│
├── features/                     # Feature-first modules
│   │
│   ├── auth/                     # Authentication (Login, Token Management)
│   │   ├── data/                 # Data layer: Repositories, Data sources (API calls), Models
│   │   ├── domain/               # Domain layer: Entities, Use cases
│   │   └── presentation/         # Presentation layer: Screens, Widgets, Riverpod Providers
│   │
│   ├── dashboard/                # Main dashboard & metrics
│   │
│   ├── items/                    # Inventory / Items Management
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── pos_transaction/          # Core POS System (Cart, Checkout)
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/         # Includes Cart Widget, Payment Screen
│   │
│   ├── cash_sessions/            # Cashier shift/session management
│   │
│   ├── attendance/               # Employee clock in/out
│   │
│   ├── history/                  # Transaction and Inventory History
│   │
│   └── settings/                 # User preferences, printer setup, etc.
│
├── l10n/                         # Localization/Internationalization files (.arb)
│
└── main.dart                     # Entry point & ProviderScope initialization
```

---

## 4. Best Practices for POS Mobile App

### A. Separation of Concerns (Clean Architecture inside Features)

- **Data Layer:** Handles external data (API calls, local database). It converts JSON from the `api` into Dart Models.
- **Domain Layer:** Contains core business logic and Entities. This layer should not depend on Flutter UI or specific external packages.
- **Presentation Layer:** Contains UI and State Management. Flutter widgets should _only_ interact with Providers/Controllers, never directly with Repositories.

### B. Network Interceptors & Authentication

Use Dio interceptors to automatically attach the `Authorization: Bearer <token>` to every request. If a request returns `401 Unauthorized` (like your `Unauthorized.jsx` handles on web), the interceptor should automatically trigger a token refresh or log the user out and redirect to the Login route.

### C. Error Handling

Never throw raw exceptions to the UI. Wrap API responses in a `Result` or `Either` type:

```dart
Future<Either<Failure, TransactionEntity>> submitTransaction(...)
```

The UI can then neatly fold this into a success snackbar or an error dialog.

### D. Offline-First / Sync Queue (Optional Phase 2)

For a POS, intermittent internet is a major risk.
Consider building a local sync queue for transactions. If the API call fails due to no internet, save the transaction locally (e.g., in Isar) and sync it seamlessly in the background once the connection is restored.

### E. Responsive UI

Since POS apps are often run on tablets natively:

- Use `LayoutBuilder` or packages like `responsive_builder` to adapt layouts.
- Example: Mobile phones show a list of items and clicking opens a cart overlay. Tablets show a split screen (Items on the left 70%, Cart on the right 30%).

## 5. Next Steps to Start Coding

1. Initialize the project: `flutter create klampis_depo_mobile`
2. Setup the `core/` folder with Dio network configuration to connect to the backend running at `C:\project\klampisDepo\api` (ensure you use your local IP, e.g., `192.168.1.x`, instead of `localhost` so the emulator/device can reach the API).
3. Implement `features/auth/` as the first vertical slice to prove connectivity.
4. Implement `features/dashboard/` and navigation using `go_router`.
5. Build out the core `pos_transaction/` and `items/` logic.
