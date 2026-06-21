package models

import (
	"time"
)

type Image struct {
	ID        uint      `gorm:"primaryKey" json:"id"`
	FileName  string    `gorm:"unique;not null;type:varchar(255)" json:"file_name"`
	Data      string    `gorm:"type:longtext;not null" json:"-"` // Base64 data
	MimeType  string    `gorm:"type:varchar(50);not null" json:"mime_type"`
	CreatedAt time.Time `gorm:"autoCreateTime" json:"created_at"`
}
