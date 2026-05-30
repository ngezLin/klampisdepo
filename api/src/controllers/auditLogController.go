package controllers

import (
	"net/http"
	"strconv"

	"kd-api/src/dtos"
	"kd-api/src/services"

	"github.com/gin-gonic/gin"
)

func GetAuditLogs(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "20"))
	entityType := c.Query("entity_type")
	entityID := c.Query("entity_id")
	action := c.Query("action")

	service := services.NewAuditLogService()
	response, err := service.GetAuditLogs(dtos.AuditLogFilter{
		Page:       page,
		PageSize:   pageSize,
		EntityType: entityType,
		EntityID:   entityID,
		Action:     action,
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, response)
}