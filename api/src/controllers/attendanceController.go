package controllers

import (
	"kd-api/src/dtos"
	"kd-api/src/services"
	"kd-api/src/utils/common"
	"net/http"

	"github.com/gin-gonic/gin"
)

// Add manual attendance
func CreateAttendance(c *gin.Context) {
	var input dtos.CreateAttendanceInput

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	userIDPtr := common.GetUserID(c)
	role := common.GetUserRole(c)

	if userIDPtr == nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "Akses tidak sah"})
		return
	}

	// Only owner/admin can create attendance for others
	if input.UserID != *userIDPtr && role != "owner" && role != "admin" {
		c.JSON(http.StatusForbidden, gin.H{"error": "Tidak diizinkan membuat absensi untuk karyawan lain"})
		return
	}

	service := services.NewAttendanceService()
	attendance, err := service.CreateAttendance(input)

    if err != nil {
        if err.Error() == "cashier has already clocked in today" {
             c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
             return
        }
        c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusCreated, attendance)
}


// Get all attendances today
func GetTodayAttendance(c *gin.Context) {
    service := services.NewAttendanceService()
    attendances, err := service.GetTodayAttendance()
    
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, attendances)
}

// Employee attendance history
func GetAttendanceHistory(c *gin.Context) {
    service := services.NewAttendanceService()
    attendances, err := service.GetAttendanceHistory()
    
    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, attendances)
}

func GetAttendances(c *gin.Context) {
    service := services.NewAttendanceService()
    attendances, err := service.GetAllAttendances()

    if err != nil {
         c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
         return
    }

    c.JSON(http.StatusOK, attendances)
}
