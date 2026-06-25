package controllers

import (
	"net/http"
	"os"
	"os/exec"
	"runtime"
	"time"

	"kd-api/src/config"

	"github.com/gin-gonic/gin"
)

func GetHealthStatus(c *gin.Context) {
	// 1. Check DB connection
	dbStatus := "connected"
	var dbPing int
	err := config.DB.Raw("SELECT 1").Scan(&dbPing).Error
	if err != nil {
		dbStatus = "disconnected: " + err.Error()
	}

	// 2. DB connection pool stats
	var activeConns, idleConns, openConns int
	sqlDB, err := config.DB.DB()
	if err == nil {
		stats := sqlDB.Stats()
		activeConns = stats.InUse
		idleConns = stats.Idle
		openConns = stats.OpenConnections
	}

	// 3. Uptime calculation
	uptime := "unknown"
	if !config.StartTime.IsZero() {
		uptime = time.Since(config.StartTime).Round(time.Second).String()
	}

	// 4. Go memory statistics
	var memStats runtime.MemStats
	runtime.ReadMemStats(&memStats)

	// Build monitoring payload
	c.JSON(http.StatusOK, gin.H{
		"status":    "UP",
		"timestamp": time.Now().Format(time.RFC3339),
		"uptime":    uptime,
		"database": gin.H{
			"status":             dbStatus,
			"active_connections": activeConns,
			"idle_connections":   idleConns,
			"open_connections":   openConns,
		},
		"system": gin.H{
			"alloc_memory_mb":      float64(memStats.Alloc) / 1024 / 1024,
			"total_alloc_memory_mb": float64(memStats.TotalAlloc) / 1024 / 1024,
			"sys_memory_mb":        float64(memStats.Sys) / 1024 / 1024,
			"num_goroutines":       runtime.NumGoroutine(),
		},
	})
}

func RestartAPI(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "Restarting KD-API service in 1 second...",
	})

	go func() {
		time.Sleep(1 * time.Second)
		os.Exit(0)
	}()
}

func RebootServer(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "Rebooting VPS server in 1 second...",
	})

	go func() {
		time.Sleep(1 * time.Second)
		exec.Command("reboot").Run()
	}()
}

func RestartMySQL(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"message": "Restarting MySQL service in 1 second...",
	})

	go func() {
		time.Sleep(1 * time.Second)
		exec.Command("systemctl", "restart", "mysql").Run()
	}()
}

func GetSystemLogs(c *gin.Context) {
	logType := c.DefaultQuery("type", "api")
	var out []byte
	var err error

	if logType == "mysql" {
		out, err = exec.Command("tail", "-n", "200", "/var/log/mysql/error.log").CombinedOutput()
	} else {
		out, err = exec.Command("journalctl", "-u", "kd-api", "-n", "200", "--no-pager").CombinedOutput()
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error":  "Failed to fetch logs: " + err.Error(),
			"output": string(out),
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"logs": string(out),
	})
}

