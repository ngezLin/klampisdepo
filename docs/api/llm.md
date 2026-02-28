# API LLM Context - KlampisDepo

## Foundation

- **Language/Runtime:** Go (Golang)
- **Framework:** Gin Web Framework
- **Database:** PostgreSQL (with GORM or direct SQL, based on `models` and `services`)
- **Base Dir:** `C:\project\klampisDepo\api`
- **Source Dir:** `C:\project\klampisDepo\api\src`

## Core Architecture

- `src/config`: Environment and DB configuration.
- `src/controllers`: Request handlers (parsing inputs, calling services).
- `src/services`: Core business logic and DB interactions.
- `src/models`: Database struct definitions.
- `src/middlewares`: Auth (JWT), Logging, CORS, Role-based access control.
- `src/routes/router.go`: Central route registration.

## Key Endpoints & RBAC

- `POST /login`: Public login.
- `GET /public/items`: Public item listing for landing page.
- `GET /items`: Authenticated item list (searchable, filterable).
- `POST /items`: Owner/Admin only.
- `POST /transactions`: Cashier/Admin/Owner.
- `GET /dashboard`: Owner only (Sales metrics).
- `GET /attendance`: Owner only.
- `GET /audit-logs`: Owner only.
- `GET /cash-sessions`: Admin/Owner (Opening/Closing shifts).

## Business Logic Notes

- **Roles:** `owner`, `admin`, `cashier`.
- **Media:** Images are stored in `./uploads` and served statically via `/uploads`.
- **Transactions:** Supports history by date, refunds, and draft transactions.

## Development Workflows

- Uses `.env` for configuration.
- Serves on port `8080` by default.
- Image compression/processing may be handled in `UploadImage` controller.
