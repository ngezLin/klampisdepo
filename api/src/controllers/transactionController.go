package controllers

import (
	"net/http"
	"strconv"

	"kd-api/src/dtos"
	"kd-api/src/services"
	"kd-api/src/utils/common"

	"github.com/gin-gonic/gin"
)


func CreateTransaction(c *gin.Context) {
	var input dtos.CreateTransactionInput

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	service := services.NewTransactionService()
	transaction, warnings, err := service.CreateTransaction(input, common.GetUserID(c), c.ClientIP())
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	response := gin.H{"transaction": transaction}
	if len(warnings) > 0 {
		response["warnings"] = warnings
	}

	c.JSON(http.StatusCreated, response)
}

func UpdateTransactionStatus(c *gin.Context) {
	id := c.Param("id")

	var input dtos.UpdateTransactionInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	service := services.NewTransactionService()
	transaction, err := service.UpdateTransactionStatus(id, input, common.GetUserID(c), c.ClientIP())
	if err != nil {
		// Distinguish between not found and other errors if needed, but for now generic 500 or 400
		if err.Error() == "transaction not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, transaction)
}

func GetDraftTransactions(c *gin.Context) {
	status := c.Query("status")
	if status == "" {
		status = "draft"
	}

	service := services.NewTransactionService()
	response, err := service.GetTransactions(dtos.TransactionFilter{
		Status: status,
		Page:   1, // Default or query param
		Limit:  100, // Or query param, assuming fetch all drafts usually
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	// Maintains original response format which was a list of transactions
	c.JSON(http.StatusOK, response.Data)
}

func DeleteTransaction(c *gin.Context) {
	id := c.Param("id")
	service := services.NewTransactionService()
	
	err := service.DeleteDraft(id, common.GetUserID(c), c.ClientIP())
	if err != nil {
		if err.Error() == "transaction not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		if err.Error() == "only draft can be deleted" {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Draft deleted"})
}

func GetTransactionByID(c *gin.Context) {
	id := c.Param("id")
	service := services.NewTransactionService()

	transaction, err := service.GetTransactionByID(id)
	if err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
		return
	}

	if transaction.Status == "draft" {
		c.JSON(http.StatusOK, transaction)
		return
	}

	c.JSON(http.StatusOK, transaction)
}

// Get all transactions
func GetTransactions(c *gin.Context) {
    page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
    limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
    filterDate := c.Query("date")

    service := services.NewTransactionService()
    response, err := service.GetTransactions(dtos.TransactionFilter{
        Page:  page,
        Limit: limit,
        Date:  filterDate,
    })

    if err != nil {
        c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
        return
    }

    c.JSON(http.StatusOK, response)
}

// Get only completed + refunded transactions (history)
func GetTransactionHistory(c *gin.Context) {
	page, _ := strconv.Atoi(c.DefaultQuery("page", "1"))
	limit, _ := strconv.Atoi(c.DefaultQuery("limit", "10"))
	filterDate := c.Query("date")

	service := services.NewTransactionService()
	response, err := service.GetTransactionHistory(dtos.TransactionFilter{
		Page:  page,
		Limit: limit,
		Date:  filterDate,
	})

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, response)
}

// Refund transaction (completed -> refunded, restore stock)
func RefundTransaction(c *gin.Context) {
	id := c.Param("id")
	service := services.NewTransactionService()
	
	transaction, err := service.RefundTransaction(id, common.GetUserID(c), c.ClientIP())
	if err != nil {
		if err.Error() == "transaction not found" {
			c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			return
		}
		if err.Error() == "only completed transactions can be refunded" {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}

	c.JSON(http.StatusOK, transaction)
}
