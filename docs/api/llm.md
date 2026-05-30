# API LLM Context - KlampisDepo

## Foundation

- **Language/Runtime:** Go (Golang)
- **Framework:** Gin Web Framework
- **Database:** MySQL (using GORM)
- **Base Dir:** `D:\project\klampisdepo\api`
- **Source Dir:** `D:\project\klampisdepo\api\src`

## Core Architecture

- `src/config`: Database connection pool configurations.
- `src/controllers`: Request handlers (delegating parsing inputs, executing business logic via services).
- `src/services`: Decoupled core business logic interfaces and DB query layer (with row-level updates lock safety).
- `src/dtos`: Encapsulated Request and Response data transfer object schemas.
- `src/models`: Database GORM struct definitions.
- `src/middlewares`: Security/Anti-bot interceptor, Auth (JWT), Rate Limiter, and Role-based access control.
- `src/routes/router.go`: Central router mapping.
- `src/utils`: Common type parsers, JWT helpers, logging formatters, and pagination tools.

## Key Endpoints & RBAC

- `POST /login`: Public login (Rate-limited to 5 requests/min/IP).
- `GET /public/items`: Public item listing for landing page.
- `GET /items`: Authenticated item list (searchable, filterable).
- `POST /items`: Owner/Admin only.
- `POST /transactions`: Cashier/Admin/Owner.
- `GET /dashboard`: Owner only (Sales, Profit, and Omzet aggregates).
- `GET /attendance`: Owner only.
- `GET /audit-logs`: Owner/Admin (System actions log).
- `GET /cash-sessions`: Admin/Owner (POS Shift Opening/Closing).

## Business Logic Notes

- **Roles:** `owner`, `admin`, `cashier`.
- **Media Uploads:** Base64 or standard multipart upload. Decoded to disk under `./uploads` and statically served via `/uploads/` route. Hides database from raw base64 bloat.
- **Transactions & Concurrency:** Concurrency-safe sales, refunds, and drafts via GORM MySQL row-level locks (`FOR UPDATE`).
- **Security:** `User.Password` is hidden from all preloaded JSON output lists (such as audit logs and logs history) using `json:"-"` serialization blocks.

## Development Workflows

- Uses `.env` for database connection details and environment configuration.
- Serves on port `8080` by default.
- Image compression/processing may be handled in `UploadImage` controller.
