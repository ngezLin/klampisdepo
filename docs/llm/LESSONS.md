# Klampis Depo Lessons Learned

This file captures patterns, common mistakes, and lessons learned to improve future coding sessions.

## Patterns & Lessons

### 1. Landing Page Redesign (May 2026)
- **Lesson**: Small business owners prefer "Human & Local" identity over "Tech Startup" jargon.
- **Pattern**: When using `replace_file_content` with imports, always check the top of the file to prevent duplicate declarations (especially `motion` from `framer-motion`).
- **Theme**: The "White and Green" palette (`green-600` + `slate-900`) was selected for a clean, trusted look.

### 2. General Interaction
- **Rule**: Always clarify the business context (e.g., "Toko Bangunan") before suggesting copy to ensure the tone is appropriate.

### 3. API Code, Security & Performance (May 2026)
- **Lesson**: **Multi-Type Case Type Switch Hazard in Go**: In a Go type switch, grouping multiple types inside a single `case` block (e.g., `case int, int64, uint64:`) forces the evaluated switch variable inside that block to remain a generic `interface{}` type. Performing a hardcast type assertion (e.g., `v.(int)`) on it will trigger a **runtime panic** if the dynamic type is different (such as `int64`).
  *   *Pattern:* Always separate numeric types into individual, explicit type cases to guarantee safe conversion.
- **Lesson**: **Hashed Password Exposure**: Struct fields containing sensitive credentials (like bcrypt hashes) must be explicitly marked with the `json:"-"` tag. If left out, the hashes will be serialized into JSON and leaked in any endpoint where GORM preloads the user model as a relation (e.g., audit history, logs, or user references).
- **Lesson**: **N+1 Aggregation Queries**: When querying a dataset (like top-selling items) that needs secondary fields (like the product name), join the referenced tables directly in GORM (`JOIN items`) instead of querying the DB inside a `for` loop. This avoids N+1 query issues and performs all logic in a single database round-trip.
