package log

import (
	"gorm.io/gorm"
)

func CreateAuditLog(
	db *gorm.DB,
	entityType string,
	action string,
	entityID uint,
	oldValue any,
	newValue any,
	changes *string,
	userID *uint,
	ipAddress string,
	description string,
) error {
	return nil
}
