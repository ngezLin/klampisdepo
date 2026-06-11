package services

import (
	"errors"
	"kd-api/src/config"
	"kd-api/src/dtos"
	"kd-api/src/models"
	"kd-api/src/utils/pagination"
	"strconv"
	"time"

	"gorm.io/gorm"
)

type POBillService interface {
	CreatePOBill(input dtos.CreatePOBillInput) (*models.POBill, error)
	GetPOBills(filter dtos.POBillFilter) (*dtos.POBillListResponse, error)
	GetPOBillByID(id uint) (*models.POBill, error)
	UpdatePOBill(id uint, input dtos.UpdatePOBillInput) (*models.POBill, error)
	MarkAsPaid(id uint) (*models.POBill, error)
	DeletePOBill(id uint) error
}

type poBillService struct{}

func NewPOBillService() POBillService {
	return &poBillService{}
}

func (s *poBillService) CreatePOBill(input dtos.CreatePOBillInput) (*models.POBill, error) {
	receivedDate, err := time.Parse("2006-01-02", input.ReceivedDate)
	if err != nil {
		return nil, errors.New("Format received_date harus YYYY-MM-DD")
	}

	dueDate, err := time.Parse("2006-01-02", input.DueDate)
	if err != nil {
		return nil, errors.New("Format due_date harus YYYY-MM-DD")
	}

	var bill models.POBill

	err = config.DB.Transaction(func(tx *gorm.DB) error {
		invoiceNum := input.InvoiceNumber
		if invoiceNum == "" {
			// Use temporary invoice number to satisfy NOT NULL constraint
			invoiceNum = "PO-TEMP-" + strconv.FormatInt(time.Now().UnixNano(), 10)
		}

		bill = models.POBill{
			InvoiceNumber: invoiceNum,
			VendorName:    input.VendorName,
			Amount:        input.Amount,
			ReceivedDate:  receivedDate,
			DueDate:       dueDate,
			Status:        "pending",
			ReceiptImage:  input.ReceiptImage,
			Notes:         input.Notes,
		}

		if err := tx.Create(&bill).Error; err != nil {
			return err
		}

		if input.InvoiceNumber == "" {
			bill.InvoiceNumber = "PO-" + strconv.FormatUint(uint64(bill.ID), 10)
			if err := tx.Save(&bill).Error; err != nil {
				return err
			}
		}

		return nil
	})

	if err != nil {
		return nil, err
	}

	return &bill, nil
}

func (s *poBillService) GetPOBills(filter dtos.POBillFilter) (*dtos.POBillListResponse, error) {
	if filter.Page < 1 {
		filter.Page = 1
	}
	if filter.PageSize < 1 {
		filter.PageSize = 10
	}
	if filter.PageSize > 100 {
		filter.PageSize = 100
	}

	p := pagination.New(filter.Page, filter.PageSize)

	var bills []models.POBill
	var total int64

	query := config.DB.Model(&models.POBill{})

	if filter.Status != "" {
		query = query.Where("status = ?", filter.Status)
	}

	if err := query.Count(&total).Error; err != nil {
		return nil, err
	}

	// Default sort by due_date ascending
	orderClause := "due_date ASC"
	if filter.SortBy == "received_date" {
		orderClause = "received_date DESC"
	} else if filter.SortBy == "amount_desc" {
		orderClause = "amount DESC"
	} else if filter.SortBy == "amount_asc" {
		orderClause = "amount ASC"
	}

	if err := query.
		Order(orderClause).
		Offset(p.Offset).
		Limit(p.PageSize).
		Find(&bills).Error; err != nil {
		return nil, err
	}

	meta := dtos.PaginationMeta{
		Page:       p.Page,
		Limit:      p.PageSize,
		Total:      total,
		TotalPages: int((total + int64(p.PageSize) - 1) / int64(p.PageSize)),
	}

	return &dtos.POBillListResponse{
		Data: bills,
		Meta: meta,
	}, nil
}

func (s *poBillService) GetPOBillByID(id uint) (*models.POBill, error) {
	var bill models.POBill
	if err := config.DB.First(&bill, id).Error; err != nil {
		return nil, errors.New("Tagihan PO tidak ditemukan")
	}
	return &bill, nil
}

func (s *poBillService) UpdatePOBill(id uint, input dtos.UpdatePOBillInput) (*models.POBill, error) {
	var bill models.POBill
	if err := config.DB.First(&bill, id).Error; err != nil {
		return nil, errors.New("Tagihan PO tidak ditemukan")
	}

	if input.InvoiceNumber != nil {
		bill.InvoiceNumber = *input.InvoiceNumber
	}
	if input.VendorName != nil {
		bill.VendorName = *input.VendorName
	}
	if input.Amount != nil && *input.Amount > 0 {
		bill.Amount = *input.Amount
	}
	if input.ReceivedDate != nil {
		receivedDate, err := time.Parse("2006-01-02", *input.ReceivedDate)
		if err != nil {
			return nil, errors.New("Format received_date harus YYYY-MM-DD")
		}
		bill.ReceivedDate = receivedDate
	}
	if input.DueDate != nil {
		dueDate, err := time.Parse("2006-01-02", *input.DueDate)
		if err != nil {
			return nil, errors.New("Format due_date harus YYYY-MM-DD")
		}
		bill.DueDate = dueDate
	}
	if input.ReceiptImage != nil {
		bill.ReceiptImage = *input.ReceiptImage
	}
	if input.Notes != nil {
		bill.Notes = *input.Notes
	}
	if input.Status != nil && (*input.Status == "paid" || *input.Status == "pending") {
		bill.Status = *input.Status
		if *input.Status == "paid" && bill.PaidDate == nil {
			now := time.Now()
			bill.PaidDate = &now
		} else if *input.Status == "pending" {
			bill.PaidDate = nil
		}
	}

	if err := config.DB.Save(&bill).Error; err != nil {
		return nil, err
	}

	return &bill, nil
}

func (s *poBillService) MarkAsPaid(id uint) (*models.POBill, error) {
	var bill models.POBill
	if err := config.DB.First(&bill, id).Error; err != nil {
		return nil, errors.New("Tagihan PO tidak ditemukan")
	}

	if bill.Status == "paid" {
		return nil, errors.New("Tagihan PO sudah lunas")
	}

	bill.Status = "paid"
	now := time.Now()
	bill.PaidDate = &now

	if err := config.DB.Save(&bill).Error; err != nil {
		return nil, err
	}

	return &bill, nil
}

func (s *poBillService) DeletePOBill(id uint) error {
	var bill models.POBill
	if err := config.DB.First(&bill, id).Error; err != nil {
		return errors.New("Tagihan PO tidak ditemukan")
	}

	if err := config.DB.Delete(&bill).Error; err != nil {
		return err
	}

	return nil
}
