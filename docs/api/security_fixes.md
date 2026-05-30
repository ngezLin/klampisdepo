# KlampisDepo API - Security, Performance, & Code Fixes Documentation

## Overview

This document records the historical security vulnerabilities and VPS crashes, as well as the latest May 2026 codebase enhancements applied to the Go API to secure the application, optimize performance, and prevent runtime failures.

---

## 1. Historical Vulnerabilities & OOM Fixes (Feb 2026)

The Ubuntu VPS (`202.10.41.223`) was historically experiencing Out-Of-Memory (OOM) crashes due to malicious automated bot scans exploiting database-related issues. The following fixes were applied:

### Hard-Capped Pagination
*   **File:** `src/controllers/itemController.go`
*   Modified `GetItems` to enforce an absolute maximum limit of 100 items per request, preventing memory exhaustion attacks from massive page size parameters (e.g., `?page_size=999999`).

### Implemented MySQL Connection Pooling
*   **File:** `src/config/database.go`
*   Configured GORM's connection pool to limit active and idle connections to prevent connection starvation under bot spam:
    ```go
    sqlDB.SetMaxIdleConns(3)
    sqlDB.SetMaxOpenConns(10)
    sqlDB.SetConnMaxLifetime(30 * time.Minute)
    sqlDB.SetConnMaxIdleTime(5 * time.Minute)
    ```

### Added Security Anti-Bot Middleware
*   **File:** `src/middlewares/securityMiddleware.go` && `main.go`
*   Created and applied a global middleware that intercepts and blocks requests to common bot vulnerability scanning paths (`/.env`, `/wp-admin`, `/Dr0v`, etc.) with a `403 Forbidden` response.

### Refactored Image Uploads to support Base64 safely
*   **File:** `src/controllers/uploadController.go`
*   Instead of storing huge `Base64` image text strings directly in the database (which triggers OOM crashes), the `/upload/image` endpoint was upgraded to decode Base64 data into physical `.jpg`/`.png` files on the disk, saving only the tiny public URL path in GORM.

### Fixed Goroutine Context Leak (Thread Safety)
*   **File:** `src/controllers/transactionController.go`
*   Fixed a race condition that would cause Go to panic when `gin.Context` was passed directly down into a background goroutine. Data (`userID`, `clientIP`) is now extracted safely beforehand.

### Added Graceful Shutdown
*   **File:** `main.go`
*   Replaced blocking `r.Run()` with `http.Server` and OS signal interception to allow active database transactions to resolve before the API stops.

---

## 2. May 2026 Code Security & Performance Upgrades

A deep codebase audit and refactoring session was executed on `2026-05-23` to resolve logic defects, performance bottlenecks, and a high-severity security leak:

### Fixed Type-Assertion Panic (Critical Code Defect)
*   **File:** `src/utils/common/user.go`
*   **Problem:** The type-switch in `GetUserID` for numerical values (`case int, int64, uint64:`) was using a hardcast `v.(int)` to extract the ID. In Go, inside a multi-type case block, the switch variable retains its static `interface{}` type. If GORM or the JWT library parsed a user ID as `int64`, the cast to `int` would fail and trigger an immediate **runtime panic**, crashing the HTTP request.
*   **Fix:** Refactored the type-switch to evaluate numerical types individually (`int`, `int64`, `uint64`, `float64`), resolving the crash risk:
    ```go
    switch val := value.(type) {
    case uint:
        id := val
        return &id
    case int:
        id := uint(val)
        return &id
    case int64:
        id := uint(val)
        return &id
    case uint64:
        id := uint(val)
        return &id
    case float64:
        id := uint(val)
        return &id
    }
    ```

### Prevented Hashed Password Exposure (High-Severity Security Leak)
*   **File:** `src/models/user.go`
*   **Problem:** The `User` struct lacked the `json:"-"` exclusion tag on the `Password` field. Whenever the `User` model was preloaded as a relation (such as in Audit Logs, Inventory History Logs, and Attendance History) and returned in API responses, the user's bcrypt-hashed passwords were fully serialized and leaked in the JSON response payload.
*   **Fix:** Added the `json:"-"` struct tag to the Password definition:
    ```go
    type User struct {
        ID       uint   `json:"id"`
        Username string `json:"username"`
        Password string `json:"-"` // Safely excludes passwords from JSON serialization
        Role     string `json:"role" gorm:"type:enum('admin','cashier','owner');default:'cashier'"`
    }
    ```
    This successfully masks user hashed passwords across all API response payloads while leaving database GORM models fully functional.

### Eliminated Aggregation N+1 Query Loop (Performance Optimization)
*   **File:** `src/services/dashboardService.go`
*   **Problem:** The `GetDashboardStats` function previously queried GORM to get the top 5 selling items, and then executed a `for` loop executing separate `SELECT` queries 5 times to fetch the item names one by one.
*   **Fix:** Performed a database `JOIN` with the `items` table directly inside the GORM query to fetch names in a single database call, removing the N+1 loop entirely:
    ```go
    if err := config.DB.Model(&models.TransactionItem{}).
        Select("transaction_items.item_id, items.name, SUM(transaction_items.quantity) as quantity").
        Joins("JOIN transactions ON transactions.id = transaction_items.transaction_id").
        Joins("JOIN items ON items.id = transaction_items.item_id").
        Where("transactions.status = ? AND transactions.deleted_at IS NULL", "completed").
        Group("transaction_items.item_id, items.name").
        Order("quantity desc").
        Limit(5).
        Scan(&topItems).Error; err != nil {
        return nil, err
    }
    ```

### Realigned Controllers with Service Layer Architecture
*   **Files:** `userController.go` & `auditLogController.go`
*   **Problem:** These two controllers bypassed the Service layer and queried `config.DB` directly inside the request handlers, violating the codebase's Service-Controller-Model architectural style.
*   **Fix:** Introduced new `UserService` (`userService.go`) and `AuditLogService` (`auditLogService.go`) files, encapsulating database queries in service interfaces and updating the controllers to call these services.
