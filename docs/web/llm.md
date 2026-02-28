# Web LLM Context - KlampisDepo

## Foundation

- **Language/Runtime:** JavaScript (React)
- **Styling:** CSS / Tailwind (based on `Unauthorized.jsx` imports where `className` is used)
- **Base Dir:** `C:\project\klampisDepo\web`
- **Main Entry:** `web/src/App.js` or `index.js`

## Core Architecture

- `src/pages`: Component-based routing views.
- `src/services`: API abstraction layer (using Axios or Fetch).
- `src/config/navigation.js`: Role-based navigation config.
- `src/routes/AppRoutes.jsx`: Central routing and Guarded Routes.
- `src/components`: Shared UI components (Modals, Tables, Forms).

## Features & Navigation

- **Dashboard:** Owner only, metrics summary.
- **Cash Sessions:** Managing POS shift start/end (Admin/Owner).
- **Items:** Product management, inventory levels.
- **Transactions:** Real-time POS interface for recording sales.
- **History:** Transaction logs and previous sessions.
- **Attendance:** Staff clock actions.
- **Audit Logs:** System activity tracking.

## State Management

- Likely uses React Context or local state for simple modules.
- `src/services/api.js` centralizes backend communication with `http://localhost:8080/api/v1`.

## Development Workflows

- `npm start`: Runs the development server.
- Handles `401 Unauthorized` by redirecting to `/login` or showing an `Unauthorized` page.
- Image uploads involve client-side compression/preview before sending to backend.
