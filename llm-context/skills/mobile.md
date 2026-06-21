# Mobile Development Skills & Best Practices (Flutter / Riverpod)

This guide documents the core skills, architectural conventions, coding patterns, and development practices for the **Klampis Depo** Flutter mobile app (`mobile`).

---

## 1. Core Coding Patterns & Best Practices

### Async Context Safety (BuildContext)
When using `BuildContext` across asynchronous gaps (e.g., after an `await`), you **must** verify that the widget or context is still mounted before interacting with it.
*   **Rule**: Always insert `if (!context.mounted) return;` immediately after the `await` before showing SnackBars, Navigating, or invoking context-dependent methods.
*   **Note**: Simply checking `if (mounted)` inside a `ConsumerState` is insufficient for the Flutter linter when referencing `context` directly in a chained method call. Explicitly check `context.mounted`.

```dart
// INCORRECT (Triggers use_build_context_synchronously warning)
final success = await printer.connectToPrinter(device);
if (mounted && success) {
  showTopSnackBar(context, 'Printer terhubung!');
}

// CORRECT
final success = await printer.connectToPrinter(device);
if (!context.mounted) return;
if (success) {
  showTopSnackBar(context, 'Printer terhubung!');
}
```

### Idempotency in Offline Sync
When implementing offline-first syncing capabilities (e.g., synchronizing local SQLite transactions with the backend via REST), you must provide a stable idempotency key to prevent duplicate transactions if a network timeout occurs but the server successfully processes the request.
*   **Rule**: The idempotency key must be derived from the stable entity ID (e.g., `tx.id`), **never** including mutable fields like `retryCount`.

```dart
// INCORRECT (Causes duplicates if a retry happens after a false-negative timeout)
final idempotencyKey = 'sync-${tx.id}-${tx.retryCount}';

// CORRECT (Stable key ensures backend idempotency block catches retries)
final idempotencyKey = 'sync-${tx.id}';
```

### Deprecated Widget Properties
Avoid using deprecated Material widget properties to maintain compatibility with future Flutter versions.
*   **Rule**: Replace `activeColor` with `activeThumbColor` in `Switch` and `SwitchListTile` components.

### Color Opacity (Precision Loss)
Flutter has deprecated `Color.withOpacity(double)` in favor of `Color.withValues(alpha: double)` to prevent precision loss.
*   **Rule**: Use `.withValues(alpha: X)` instead of `.withOpacity(X)`.

```dart
// INCORRECT
color: Colors.black.withOpacity(0.02)

// CORRECT
color: Colors.black.withValues(alpha: 0.02)
```

### Sharing Files & Text
Use the modern `share_plus` package instead of the deprecated `share` package.
*   **Rule**: Use `SharePlus.instance.share(ShareParams(...))` instead of `Share.share` or `Share.shareXFiles`.

```dart
// CORRECT
await SharePlus.instance.share(ShareParams(
  files: [XFile(filePath)], 
  subject: 'Struk Belanja'
));
```
