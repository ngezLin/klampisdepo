package middlewares

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// SecurityMiddleware blocks common bot scanners and malicious paths
// that check for sensitive files like .env, .git, etc.
func SecurityMiddleware() gin.HandlerFunc {
	// List of paths commonly scanned by bots
	blockedPaths := []string{
		"/.env",
		"/.git",
		"/wp-admin",
		"/wp-login",
		"/phpmyadmin",
		"/check_health",
		"/actuator",
		"/.aws",
		"/vendor",
	}

	return func(c *gin.Context) {
		path := c.Request.URL.Path

		for _, bp := range blockedPaths {
			if strings.HasPrefix(path, bp) || strings.Contains(path, "Dr0v") {
				// Abort the request immediately with a 403 Forbidden
				// without doing any further processing.
				c.AbortWithStatus(http.StatusForbidden)
				return
			}
		}

		c.Next()
	}
}
