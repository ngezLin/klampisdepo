package controllers

import (
	"net/http"
	"strconv"

	"kd-api/src/dtos"
	"kd-api/src/services"

	"github.com/gin-gonic/gin"
)

// CreatePOBill handles POST /po-bills
func CreatePOBill(c *gin.Context) {
	var input dtos.CreatePOBillInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	service := services.NewPOBillService()
	bill, err := service.CreatePOBill(input)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusCreated, bill)
}

// GetPOBills handles GET /po-bills
func GetPOBills(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	pageSize, _ := strconv.Atoi(c.DefaultQuery("page_size", "10"))
	status := c.Query("status")
	sortBy := c.Query("sort_by")

	service := services.NewPOBillService()
	response, err := service.GetPOBills(dtos.POBillFilter{
		Page:     page,
		PageSize: pageSize,
		Status:   status,
		SortBy:   sortBy,
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Gagal mengambil data tagihan PO: " + err.Error()})
		return
	}

	c.JSON(http.StatusOK, response)
}

// GetPOBillByID handles GET /po-bills/:id
func GetPOBillByID(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	service := services.NewPOBillService()
	bill, err := service.GetPOBillByID(uint(id))
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, bill)
}

// UpdatePOBill handles PUT /po-bills/:id
func UpdatePOBill(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	var input dtos.UpdatePOBillInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	service := services.NewPOBillService()
	bill, err := service.UpdatePOBill(uint(id), input)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, bill)
}

// MarkAsPaid handles PUT /po-bills/:id/pay
func MarkAsPaid(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	service := services.NewPOBillService()
	bill, err := service.MarkAsPaid(uint(id))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, bill)
}

// DeletePOBill handles DELETE /po-bills/:id
func DeletePOBill(c *gin.Context) {
	idStr := c.Param("id")
	id, err := strconv.ParseUint(idStr, 10, 32)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID tidak valid"})
		return
	}

	service := services.NewPOBillService()
	err = service.DeletePOBill(uint(id))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Tagihan PO berhasil dihapus"})
}
