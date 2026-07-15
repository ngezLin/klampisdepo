package middlewares

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"io"
	"net/http"
	"strconv"
	"sync"
	"time"

	"github.com/gin-gonic/gin"
)

var (
	requestLocks = make(map[string]time.Time)
	locksMu      sync.Mutex
)

// DebounceMiddleware prevents duplicate POST, PUT, PATCH, or DELETE requests within a short window.
// It generates a request fingerprint using:
// 1. User ID (or client IP if not authenticated)
// 2. HTTP Method
// 3. Request URL Path
// 4. SHA-256 Hash of the Request Body
func DebounceMiddleware(window time.Duration) gin.HandlerFunc {
	return func(c *gin.Context) {
		// Only apply to modifying HTTP methods
		method := c.Request.Method
		if method != http.MethodPost && method != http.MethodPut && method != http.MethodPatch && method != http.MethodDelete {
			c.Next()
			return
		}

		// Read the request body
		var bodyBytes []byte
		if c.Request.Body != nil {
			var err error
			bodyBytes, err = io.ReadAll(c.Request.Body)
			if err != nil {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to read request body"})
				c.Abort()
				return
			}
			// Restore request body so other handlers/controllers can read it
			c.Request.Body = io.NopCloser(bytes.NewBuffer(bodyBytes))
		}

		// Generate a signature for the request
		// 1. Identify User (via userID context set by AuthMiddleware)
		userIDVal, exists := c.Get("userID")
		userIDStr := ""
		if exists {
			switch uid := userIDVal.(type) {
			case uint:
				userIDStr = strconv.FormatUint(uint64(uid), 10)
			case int:
				userIDStr = strconv.FormatInt(int64(uid), 10)
			case float64:
				userIDStr = strconv.FormatUint(uint64(uid), 10)
			case string:
				userIDStr = uid
			}
		}

		// Fallback to client IP if not authenticated
		if userIDStr == "" {
			userIDStr = c.ClientIP()
		}

		// 2. Hash of the request body to distinguish between different actions/items
		hasher := sha256.New()
		hasher.Write(bodyBytes)
		bodyHash := hex.EncodeToString(hasher.Sum(nil))

		// Signature combines: identity, method, path, and request body signature
		signature := userIDStr + ":" + method + ":" + c.Request.URL.Path + ":" + bodyHash

		now := time.Now()

		locksMu.Lock()
		lastRequestTime, locked := requestLocks[signature]
		if locked && now.Sub(lastRequestTime) < window {
			locksMu.Unlock()
			c.JSON(http.StatusConflict, gin.H{
				"error": "Duplicate request detected. Please wait a moment.",
			})
			c.Abort()
			return
		}

		// Lock this request signature
		requestLocks[signature] = now
		locksMu.Unlock()

		// Run a cleanup goroutine to release the lock after the window expires
		go func(sig string, timestamp time.Time) {
			time.Sleep(window)
			locksMu.Lock()
			// Only delete if the timestamp matches (ensuring we don't clear a newer request's lock)
			if t, ok := requestLocks[sig]; ok && t.Equal(timestamp) {
				delete(requestLocks, sig)
			}
			locksMu.Unlock()
		}(signature, now)

		c.Next()
	}
}
