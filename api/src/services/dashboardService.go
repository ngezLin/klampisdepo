package services

import (
	"kd-api/src/config"
	"kd-api/src/dtos"
	"kd-api/src/models"
	"time"
)

type DashboardService interface {
	GetDashboardStats() (*dtos.DashboardStats, error)
}

type dashboardService struct{}

func NewDashboardService() DashboardService {
	return &dashboardService{}
}

func (s *dashboardService) GetDashboardStats() (*dtos.DashboardStats, error) {
	var todayProfit float64
	var monthlyProfit float64
	var todayOmzet float64
	var monthlyOmzet float64
	var todayTransactions int64
	var lowStock int64
	var topItems []dtos.TopItem

	today := time.Now().Format("2006-01-02")
	thisMonth := time.Now().Format("2006-01")

	// Calculate today's profit and omzet using SQL aggregation (no loading into Go memory)
	var todayResult struct {
		Profit float64
		Omzet  float64
	}
	if err := config.DB.Model(&models.TransactionItem{}).
		Select(
			"COALESCE(SUM(transaction_items.quantity * (transaction_items.price - items.buy_price)), 0) AS profit, "+
				"COALESCE(SUM(transaction_items.quantity * transaction_items.price), 0) AS omzet",
		).
		Joins("JOIN transactions ON transactions.id = transaction_items.transaction_id").
		Joins("JOIN items ON items.id = transaction_items.item_id").
		Where("transactions.status = ? AND DATE(transactions.created_at) = ? AND transactions.deleted_at IS NULL", "completed", today).
		Scan(&todayResult).Error; err != nil {
		return nil, err
	}
	todayProfit = todayResult.Profit
	todayOmzet = todayResult.Omzet

	// Calculate monthly profit and omzet using SQL aggregation
	var monthlyResult struct {
		Profit float64
		Omzet  float64
	}
	if err := config.DB.Model(&models.TransactionItem{}).
		Select(
			"COALESCE(SUM(transaction_items.quantity * (transaction_items.price - items.buy_price)), 0) AS profit, "+
				"COALESCE(SUM(transaction_items.quantity * transaction_items.price), 0) AS omzet",
		).
		Joins("JOIN transactions ON transactions.id = transaction_items.transaction_id").
		Joins("JOIN items ON items.id = transaction_items.item_id").
		Where("transactions.status = ? AND DATE_FORMAT(transactions.created_at, '%Y-%m') = ? AND transactions.deleted_at IS NULL", "completed", thisMonth).
		Scan(&monthlyResult).Error; err != nil {
		return nil, err
	}
	monthlyProfit = monthlyResult.Profit
	monthlyOmzet = monthlyResult.Omzet

	// Count today's transactions
	if err := config.DB.Model(&models.Transaction{}).
		Where("status = ? AND DATE(created_at) = ?", "completed", today).
		Count(&todayTransactions).Error; err != nil {
		return nil, err
	}

	// Count low stock items (<5)
	if err := config.DB.Model(&models.Item{}).Where("stock < ?", 5).Count(&lowStock).Error; err != nil {
		return nil, err
	}

	// Get top selling items (top 5)
	if err := config.DB.Model(&models.TransactionItem{}).
		Select("item_id, SUM(quantity) as quantity").
		Joins("JOIN transactions ON transactions.id = transaction_items.transaction_id").
		Where("transactions.status = ?", "completed").
		Group("item_id").
		Order("quantity desc").
		Limit(5).
		Scan(&topItems).Error; err != nil {
		return nil, err
	}

	// Populate item names for top items
	for i, ti := range topItems {
		var item models.Item
		if err := config.DB.First(&item, ti.ItemID).Error; err == nil {
			topItems[i].Name = item.Name
		}
	}

	return &dtos.DashboardStats{
		TodayProfit:       todayProfit,
		MonthlyProfit:     monthlyProfit,
		TodayOmzet:        todayOmzet,
		MonthlyOmzet:      monthlyOmzet,
		TodayTransactions: todayTransactions,
		LowStock:          lowStock,
		TopSellingItems:   topItems,
	}, nil
}
