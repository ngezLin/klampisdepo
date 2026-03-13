package middlewares

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/ulule/limiter/v3"
	mgin "github.com/ulule/limiter/v3/drivers/middleware/gin"
	"github.com/ulule/limiter/v3/drivers/store/memory"
)

// LoginRateLimiter creates a rate limiter middleware for the login endpoint.
// Allows 5 requests per minute per IP address to prevent brute-force attacks.
func LoginRateLimiter() gin.HandlerFunc {
	rate, err := limiter.NewRateFromFormatted("5-M")
	if err != nil {
		panic(err)
	}

	store := memory.NewStore()

	instance := limiter.New(store, rate)

	middleware := mgin.NewMiddleware(instance,
		mgin.WithLimitReachedHandler(func(c *gin.Context) {
			c.JSON(http.StatusTooManyRequests, gin.H{
				"error": "Too many login attempts. Please try again later.",
			})
			c.Abort()
		}),
	)

	return middleware
}
