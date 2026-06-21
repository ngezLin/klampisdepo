# Klampis Depo - Technical Skills & Runbooks

This guide outlines core skills, exact command lines, architecture patterns, and critical pitfalls across backend deployment, Go development, Flutter mobile coding, and React frontend work. Refer to this to eliminate trial-and-error.

---

## 1. Deployment Skills & Runbook

### Environment Details
* **Production VPS IP**: `202.10.41.223` (Running Linux)
* **Production API Domain**: `https://api.klampisdepo.com`
* **SSH Key Path**: `C:\Users\vince\OneDrive\Documents\ssh\id_ed25519`
* **Nginx configuration**: Proxies incoming public domain traffic to port `8080` (where `kd-api` service listens).

### Build & Deploy Commands
To compile the API backend for the production VPS and restart the service, execute:

1. **Cross-Compile for Linux (AMD64)**:
   Run from the `api` project directory:
   ```powershell
   $env:GOOS="linux"; $env:GOARCH="amd64"; go build -o main .
   ```
2. **Secure Copy (SCP) to VPS Temp Directory**:
   ```powershell
   scp -i C:\Users\vince\OneDrive\Documents\ssh\id_ed25519 -o StrictHostKeyChecking=no main root@202.10.41.223:/tmp/kd-api
   ```
3. **Execute Deployment & Restart via SSH**:
   Move the binary to the production path `/var/www/kd-api`, set executable flags, and restart the systemd unit `kd-api`:
   ```powershell
   ssh -i C:\Users\vince\OneDrive\Documents\ssh\id_ed25519 -o StrictHostKeyChecking=no root@202.10.41.223 "mv /var/www/kd-api /var/www/kd-api.backup.previous; mv /tmp/kd-api /var/www/kd-api; chmod +x /var/www/kd-api; systemctl restart kd-api"
   ```
4. **Monitor Log Outputs**:
   ```powershell
   ssh -i C:\Users\vince\OneDrive\Documents\ssh\id_ed25519 -o StrictHostKeyChecking=no root@202.10.41.223 "journalctl -u kd-api -n 40 --no-pager"
   ```

---

## 2. Backend Development Skills (Go / Gin / GORM)

### Architecture
We follow a classic **Model-Service-Controller** split:
* **Models (`api/src/models/`)**: Define GORM struct models. Ensure fields containing sensitive data (e.g. hashed passwords) are marked `json:"-"` to block leakages in preloaded structs.
* **Services (`api/src/services/`)**: Write the core business logic.
* **Controllers (`api/src/controllers/`)**: Handle HTTP binding, parameter sanitization, and output mapping.

### Performance & Query Rules
* **Avoid N+1 Queries**: Never query the database inside loops. Perform direct `JOIN` preloads in GORM (e.g., `db.Preload("Item")` or `db.Joins("Item")`) instead of running secondary queries per row.
* **Database Migrations**: Database tables are managed via `db.AutoMigrate(...)` inside `api/src/config/database.go`. Always add new models to this list.
* **Numeric Type Switches**: In Go, grouping multiple types inside a single case of a type switch (e.g. `case int, int64, float64:`) makes the variable generic. Hardcasting it (e.g. `v.(int)`) will cause **runtime panics** if the type varies. Use individual, explicit type cases.
* **Date Handling**: When implementing backend queries filtering by date ranges, query parameters should be string dates format `YYYY-MM-DD`. Ensure search ranges handle time offsets (e.g. appending `" 23:59:59"` to the end date parameter).

---

## 3. Mobile Development Skills (Flutter / Riverpod)

### Architecture & State Management
* We use **Riverpod** for dependency injection and state management.
* Network client is configured via `dioProvider` in `lib/core/network/dio_client.dart` and automatically attaches JWT Bearer tokens to authorized requests.
* Production API Base URL default: `https://api.klampisdepo.com`.

### Critical Dialog Rebuild Trap
> [!CAUTION]
> **Do NOT use inline `Consumer` builders inside `showDialog`**.
> Watching providers using the parent context's `ref` or using nested `Consumer` blocks where the variable name `ref` or `context` shadows outer widgets causes layout state-update loss. The dialog gets stuck on `AsyncLoading` (green loading dot) because overlay route updates are missed.
> 
> **Standard Fix Pattern**:
> Write all dialogs as custom private `ConsumerWidget` subclasses (e.g., `class _AttendanceHistoryDialog extends ConsumerWidget`) and return them from `showDialog(builder: (context) => const _AttendanceHistoryDialog())`.

### Build & Lint Verification
Always run these checks from the `mobile` project directory before committing or releasing:
* **Code Quality Scan**:
  ```powershell
  C:\flutter\bin\flutter.bat analyze
  ```
* **Production Release Package Build**:
  ```powershell
  C:\flutter\bin\flutter.bat build apk --release
  ```
  The packaged binary output location is: `build\app\outputs\flutter-apk\app-release.apk`.

### Locale & Formatting
* Call `await initializeDateFormatting('id_ID', null);` during initialization.
* Format dates via `DateFormat('dd MMMM yyyy', 'id_ID')`.
* Format currencies using Indonesian Rupiah: `NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)`.

---

## 4. Frontend Web Development Skills (React / Tailwind)

### Tone & Copy
* Tone must be **Human, Local, and Trusted**. Avoid tech startup hype, buzzwords, or cold corporate speak. Use clean, natural Indonesian.
* Target business: **UD. Klampis Depo (Toko Bangunan / Building Materials)** in Surabaya.

### Styling & Theme Rules
* **Theme**: Green and white.
* **Tailwind CSS Utility Palette**:
  * Primary Green: `green-600` (`#16a34a`) or `emerald-600`.
  * Dark Headings: `slate-900`.
  * Body text: `slate-600` or `slate-700`.
  * Backgrounds: `bg-white`, `bg-slate-50`, or `bg-gray-50`.
* Always inspect imports to prevent duplicate imports (e.g. framer-motion library imports) when doing edits.
