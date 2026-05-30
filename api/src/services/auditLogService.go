package services

import (
	"kd-api/src/config"
	"kd-api/src/dtos"
	"kd-api/src/models"
)

type AuditLogService interface {
	GetAuditLogs(filter dtos.AuditLogFilter) (*dtos.AuditLogListResponse, error)
}

type auditLogService struct{}

func NewAuditLogService() AuditLogService {
	return &auditLogService{}
}

func (s *auditLogService) GetAuditLogs(filter dtos.AuditLogFilter) (*dtos.AuditLogListResponse, error) {
	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 || filter.PageSize > 100 {
		filter.PageSize = 20
	}

	var logs []models.AuditLog
	var total int64

	query := config.DB.Model(&models.AuditLog{})

	if filter.EntityType != "" {
		query = query.Where("entity_type = ?", filter.EntityType)
	}
	if filter.EntityID != "" {
		query = query.Where("entity_id = ?", filter.EntityID)
	}
	if filter.Action != "" {
		query = query.Where("action = ?", filter.Action)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, err
	}

	offset := (filter.Page - 1) * filter.PageSize
	if err := query.
		Preload("User").
		Order("created_at DESC").
		Offset(offset).
		Limit(filter.PageSize).
		Find(&logs).Error; err != nil {
		return nil, err
	}

	return &dtos.AuditLogListResponse{
		Data:       logs,
		Page:       filter.Page,
		PageSize:   filter.PageSize,
		TotalItems: total,
	}, nil
}
