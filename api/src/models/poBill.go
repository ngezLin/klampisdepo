package models

import (
	"time"
)

type POBill struct {
	ID            uint       `gorm:"primaryKey" json:"id"`
	InvoiceNumber string     `gorm:"type:varchar(100);not null" json:"invoice_number"`
	VendorName    string     `gorm:"type:varchar(255);not null" json:"vendor_name"`
	Amount        float64    `gorm:"type:decimal(15,2);not null" json:"amount"`
	ReceivedDate  time.Time  `gorm:"not null" json:"received_date"`
	DueDate       time.Time  `gorm:"not null" json:"due_date"`
	Status        string     `gorm:"type:varchar(50);default:'pending';not null" json:"status"` // 'pending', 'paid'
	PaidDate      *time.Time `json:"paid_date,omitempty"`
	ReceiptImage  string     `gorm:"type:text" json:"receipt_image"`
	Notes         string     `gorm:"type:text" json:"notes"`
	CreatedAt     time.Time  `json:"created_at"`
	UpdatedAt     time.Time  `json:"updated_at"`
}
