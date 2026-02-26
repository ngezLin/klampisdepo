package routes

import (
	"kd-api/src/controllers"
	"kd-api/src/middlewares"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {

	r.POST("/login", controllers.Login)

	// Public items buat landing page
	r.GET("/public/items", controllers.GetItems)
	r.GET("/public/items/search", controllers.GetItemsByName)
	r.GET("/public/items/:id", controllers.GetItemByID)

	// Inventory
	inventory := r.Group("/inventory")
	inventory.Use(middlewares.AuthMiddleware(), middlewares.RoleMiddleware("owner"))
	{
		inventory.GET("/history", controllers.GetInventoryHistory)
	}

	// Items 
	items := r.Group("/items")
	items.Use(middlewares.AuthMiddleware())
	{
		items.GET("/", controllers.GetItems)
		items.GET("/search", controllers.GetItemsByName)
		items.GET("/:id", controllers.GetItemByID)     
		items.POST("/", middlewares.RoleMiddleware("owner", "admin"), controllers.CreateItem)
		items.PUT("/:id", middlewares.RoleMiddleware("owner", "admin"), controllers.UpdateItem)
		items.DELETE("/:id", middlewares.RoleMiddleware("owner", "admin"), controllers.DeleteItem)
		items.POST("/bulk", middlewares.RoleMiddleware("owner", "admin"), controllers.BulkCreateItems)
		items.GET("/export/csv", middlewares.RoleMiddleware("owner", "admin"), controllers.ExportItems)
	}

	// Static route to serve uploaded image files
	r.Static("/uploads", "./uploads")

	// Uploads
	uploadRoute := r.Group("/upload")
	uploadRoute.Use(middlewares.AuthMiddleware()) // require login
	{
		uploadRoute.POST("/image", middlewares.RoleMiddleware("owner", "admin"), controllers.UploadImage)
	}

	// Transactions
	transactions := r.Group("/transactions")
	transactions.Use(middlewares.AuthMiddleware(), middlewares.RoleMiddleware("owner", "admin", "cashier"))
	{
		transactions.POST("/", controllers.CreateTransaction)
		transactions.GET("/", controllers.GetTransactions)
		transactions.GET("/history", controllers.GetTransactionHistory)
		transactions.GET("/:id", controllers.GetTransactionByID)
		transactions.PATCH("/:id", controllers.UpdateTransactionStatus)
		transactions.GET("/history/by-date", controllers.GetTransactionHistoryByDate)

		transactions.POST("/:id/refund", controllers.RefundTransaction)
		transactions.GET("/drafts", controllers.GetDraftTransactions)
		transactions.DELETE("/:id", controllers.DeleteTransaction)
	}

	// Dashboard
	dashboard := r.Group("/dashboard")
	dashboard.Use(middlewares.AuthMiddleware(), middlewares.RoleMiddleware("owner"))
	{
		dashboard.GET("/", controllers.GetDashboard)
	}

	// Attendance (owner only)
	attendance := r.Group("/attendance")
	attendance.Use(middlewares.AuthMiddleware(), middlewares.RoleMiddleware("owner"))
	{
		attendance.GET("/", controllers.GetAttendances)
		attendance.POST("/", controllers.CreateAttendance)
		attendance.GET("/today", controllers.GetTodayAttendance)
		attendance.GET("/history", controllers.GetAttendanceHistory)
	}

	// Users (owner only)
	users := r.Group("/users")
	users.Use(middlewares.AuthMiddleware(), middlewares.RoleMiddleware("owner"))
	{
		users.GET("/", controllers.GetUsers)
	}

	// Audit logs (owner only)
	audit := r.Group("/audit-logs")
	audit.Use(middlewares.AuthMiddleware(), middlewares.RoleMiddleware("owner"))
	{
		audit.GET("/", controllers.GetAuditLogs)
	}

	cash := r.Group("/cash-sessions")
	cash.Use(middlewares.AuthMiddleware(), middlewares.RoleMiddleware("owner", "admin"))
	{
		cash.GET("/current", controllers.GetCurrentCashSession)
		cash.GET("/history", controllers.GetCashSessionHistory)
		cash.POST("/open", controllers.OpenCashSession)
		cash.POST("/close", controllers.CloseCashSession)
	}
}