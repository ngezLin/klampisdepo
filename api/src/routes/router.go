package routes

import (
	"kd-api/src/controllers"
	"kd-api/src/middlewares"

	"github.com/gin-gonic/gin"
)

func RegisterRoutes(r *gin.Engine) {

	r.POST("/login", middlewares.LoginRateLimiter(), controllers.Login)

	// Serve Images from DB
	r.GET("/images/:filename", controllers.ServeImage)

	// Health (dev only)
	health := r.Group("/health")
	health.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter(), middlewares.RoleMiddleware("dev"))
	{
		health.GET("/", controllers.GetHealthStatus)
	}
	// Inventory
	inventory := r.Group("/inventory")
	inventory.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter(), middlewares.RoleMiddleware("owner", "admin"))
	{
	inventory.GET("/history", controllers.GetInventoryHistory)
	}	

	// Items 
	items := r.Group("/items")
	items.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter())
	{
		items.GET("/", controllers.GetItems)
		items.GET("/search", controllers.GetItems)
		items.GET("/:id", controllers.GetItemByID)     
		items.POST("/", middlewares.RoleMiddleware("owner", "admin", "cashier"), controllers.CreateItem)
		items.PUT("/:id", middlewares.RoleMiddleware("owner", "admin", "cashier"), controllers.UpdateItem)
		items.DELETE("/:id", middlewares.RoleMiddleware("owner", "admin", "cashier"), controllers.DeleteItem)
		items.POST("/bulk", middlewares.RoleMiddleware("owner", "admin", "cashier"), controllers.BulkCreateItems)
		items.GET("/export/csv", middlewares.RoleMiddleware("owner", "admin", "cashier"), controllers.ExportItems)

		// manual stock adjustments for a given item
		items.GET("/:id/manual-changes", middlewares.RoleMiddleware("owner", "admin", "cashier"), controllers.GetManualStockChanges)
	}

	// Static route to serve uploaded image files
	r.Static("/uploads", "./uploads")

	// Uploads
	uploadRoute := r.Group("/upload")
	uploadRoute.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter()) // require login
	{
		uploadRoute.POST("/image", middlewares.RoleMiddleware("owner", "admin"), controllers.UploadImage)
	}

	// Transactions
	transactions := r.Group("/transactions")
	transactions.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter(), middlewares.RoleMiddleware("owner", "admin", "cashier"))
	{
		transactions.POST("/", controllers.CreateTransaction)
		transactions.GET("/", controllers.GetTransactions)
		transactions.GET("/history", controllers.GetTransactionHistory)
		transactions.GET("/:id", controllers.GetTransactionByID)
		transactions.PATCH("/:id", controllers.UpdateTransactionStatus)
		transactions.GET("/history/by-date", controllers.GetTransactionHistory)

		transactions.POST("/:id/refund", controllers.RefundTransaction)
		transactions.GET("/drafts", controllers.GetDraftTransactions)
		transactions.DELETE("/:id", controllers.DeleteTransaction)
	}

	// Dashboard
	dashboard := r.Group("/dashboard")
	dashboard.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter(), middlewares.RoleMiddleware("owner"))
	{
		dashboard.GET("/", controllers.GetDashboard)
	}

	// Attendance
	attendance := r.Group("/attendance")
	attendance.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter())
	{
		attendance.GET("/", middlewares.RoleMiddleware("owner"), controllers.GetAttendances)
		attendance.POST("/", middlewares.RoleMiddleware("owner", "admin", "cashier"), controllers.CreateAttendance)
		attendance.GET("/today", middlewares.RoleMiddleware("owner", "admin", "cashier"), controllers.GetTodayAttendance)
		attendance.GET("/history", middlewares.RoleMiddleware("owner", "admin"), controllers.GetAttendanceHistory)
	}

	// Users (owner & dev)
	users := r.Group("/users")
	users.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter(), middlewares.RoleMiddleware("owner", "dev"))
	{
		users.GET("/", controllers.GetUsers)
		users.POST("/", controllers.CreateUser)
		users.PUT("/:id", controllers.UpdateUser)
		users.DELETE("/:id", controllers.DeleteUser)
	}

	// PO Bills (owner & admin only)
	poBills := r.Group("/po-bills")
	poBills.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter(), middlewares.RoleMiddleware("owner", "admin"))
	{
		poBills.POST("/", controllers.CreatePOBill)
		poBills.GET("/", controllers.GetPOBills)
		poBills.GET("/:id", controllers.GetPOBillByID)
		poBills.PUT("/:id", controllers.UpdatePOBill)
		poBills.PUT("/:id/pay", controllers.MarkAsPaid)
		poBills.DELETE("/:id", controllers.DeletePOBill)
	}

	// Cash Sessions (owner, admin, cashier)
	cash := r.Group("/cash-sessions")
	cash.Use(middlewares.AuthMiddleware(), middlewares.GeneralRateLimiter(), middlewares.RoleMiddleware("owner", "admin", "cashier"))
	{
		cash.GET("/current", controllers.GetCurrentCashSession)
		cash.GET("/history", controllers.GetCashSessionHistory)
		cash.POST("/open", controllers.OpenCashSession)
		cash.POST("/close", controllers.CloseCashSession)
	}
}