package dtos

import "kd-api/src/models"

type AuditLogFilter struct {
	Page       int
	PageSize   int
	EntityType string
	EntityID   string
	Action     string
}

type AuditLogListResponse struct {
	Data       []models.AuditLog `json:"data"`
	Page       int               `json:"page"`
	PageSize   int               `json:"page_size"`
	TotalItems int64             `json:"total_items"`
}
