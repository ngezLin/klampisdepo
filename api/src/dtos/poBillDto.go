package dtos

type CreatePOBillInput struct {
	InvoiceNumber string  `json:"invoice_number"`
	VendorName    string  `json:"vendor_name" binding:"required"`
	Amount        float64 `json:"amount" binding:"required,gt=0"`
	ReceivedDate  string  `json:"received_date" binding:"required"` // Format: YYYY-MM-DD
	DueDate       string  `json:"due_date" binding:"required"`      // Format: YYYY-MM-DD
	ReceiptImage  string  `json:"receipt_image"`
	Notes         string  `json:"notes"`
}

type UpdatePOBillInput struct {
	InvoiceNumber *string  `json:"invoice_number"`
	VendorName    *string  `json:"vendor_name"`
	Amount        *float64 `json:"amount"`
	ReceivedDate  *string  `json:"received_date"`
	DueDate       *string  `json:"due_date"`
	ReceiptImage  *string  `json:"receipt_image"`
	Notes         *string  `json:"notes"`
	Status        *string  `json:"status"`
}

type POBillFilter struct {
	Page     int    `json:"page"`
	PageSize int    `json:"page_size"`
	Status   string `json:"status"`
	SortBy   string `json:"sort_by"`
}

type POBillListResponse struct {
	Data interface{}    `json:"data"`
	Meta PaginationMeta `json:"meta"`
}
