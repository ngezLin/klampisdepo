package controllers

import (
	"net/http"

	"kd-api/src/services"

	"github.com/gin-gonic/gin"
)

func GetUsers(c *gin.Context) {
	service := services.NewUserService()
	users, err := service.GetUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, users)
}