# KlampisDepo API - Security & OOM Fixes Documentation

## Overview

This document records the security vulnerabilities discovered on `2026-02-28`, the Out-Of-Memory (OOM) crashes the VPS was experiencing, and the comprehensive fixes applied to the Go API source code to secure the server against malicious bots.

## 1. The Core Problem (OOM Crashes)

The Ubuntu VPS (`202.10.41.223`) was repeatedly crashing because the MySQL process (`1937`) ran out of memory. This was triggered by malicious automated bots scanning the API and exploiting the following vulnerabilities:

1. **Uncapped Pagination:** Bots requested massive datasets (e.g., `?page_size=999999`) on public endpoints, forcing MySQL to load the entire database into RAM, causing an instant server crash.
2. **Database Connection Leaks:** The API lacked proper MySQL connection pooling. Spamming bots caused the Go backend to open hundreds of simultaneous connections, draining system memory.
3. **Unfiltered Bot Scans:** Bots repeatedly hit sensitive paths (`/.env`, `/.git`, `/check_health`).

## 2. API Bug Fixes & Code Improvements

### Hard-Capped Pagination

**File:** `src/controllers/itemController.go`
Modified `GetItems` to enforce an absolute maximum limit of 100 items per request, effectively neutralizing memory exhaustion attacks on the database.

### Implemented MySQL Connection Pooling

**File:** `src/config/database.go`
Configured the connection pool to limit active and idle connections:

```go
sqlDB.SetMaxIdleConns(5)
sqlDB.SetMaxOpenConns(20)
sqlDB.SetConnMaxLifetime(time.Hour)
```

### Added Security Anti-Bot Middleware

**File:** `src/middlewares/securityMiddleware.go` && `main.go`
Created and applied a global middleware that intercepts and blocks requests to common bot vulnerability scanning paths (`/.env`, `/wp-admin`, `/Dr0v`, etc.) with a `403 Forbidden`, saving CPU processing power.

### Refactored Image Uploads to support Base64 safely

**File:** `src/controllers/uploadController.go`
Instead of saving huge `Base64` image text strings inside the database (which exacerbates OOM crashes), the `/upload/image` endpoint was upgraded to securely parse incoming JSON Base64 data, decode it into a physical `.jpg`/`.png` file, save it to the `uploads/` disk directory, and only store the tiny URL in the database.

### Fixed Goroutine Context Leak (Thread Safety)

**File:** `src/controllers/transactionController.go`
Fixed a race condition that would cause Go to panic when `gin.Context` was passed directly down into a background goroutine. Data (`userID`, `clientIP`) is now extracted safely beforehand.

### Added Graceful Shutdown

**File:** `main.go`
Replaced blocking `r.Run()` with `http.Server` and OS signal interception to allow active database transactions to resolve before the API stops.

## 3. Deployment Server Adjustments

- The API binary was renamed to `kdapi1.0` and deployed to `/var/www/kd-api/`.
- Due to the absence of a `systemctl` unit file, the service runs in the background using `nohup`.
- MySQL remote bindings (`bind-address`) were reconfigured to `0.0.0.0` in `/etc/mysql/mysql.conf.d/mysqld.cnf` to allow tools like DBeaver to connect.
- VPS root passwords were changed and `PasswordAuthentication no` was enforced in `/etc/ssh/sshd_config` to prevent future SSH brute force attacks.
