# Klampis Depo Technical Guidelines

## Frontend (React + Tailwind)
- **Styling**: Use Tailwind CSS. Follow the "White and Green" theme:
    - Primary Green: `green-600`
    - Text: `slate-900` for headings, `slate-600` for body.
    - Backgrounds: `bg-white` or `bg-slate-50`.
- **Components**: Keep components modular and reusable. Place landing page components in `web/src/components/landing/`.
- **Tone**: Use natural Indonesian. Avoid corporate buzzwords.
- **Icons**: Use `lucide-react`.

## Backend (Go + Gin + GORM)
- **Architecture**: Follow the Service-Controller-Model pattern.
    - `api/src/controllers/`: Handle HTTP requests/responses.
    - `api/src/services/`: Contain business logic.
    - `api/src/models/`: Database schema definitions.
- **Database**: Use GORM but ensure raw SQL is used when performance or complex joins are required (per migration guidelines).
- **Naming**: Use camelCase for JSON fields and PascalCase for Go structs/functions.

## General Coding Standards
- **Imports**: Avoid duplicate imports. Group imports (Stdlib, Third-party, Internal).
- **Comments**: Keep documentation integrity. Preserve existing comments.
- **Error Handling**: Always handle errors explicitly in Go. Use consistent JSON error responses in controllers.
- **Security**: Never expose sensitive credentials in the codebase.
