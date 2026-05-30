package services

import (
	"kd-api/src/config"
	"kd-api/src/models"
)

type UserService interface {
	GetUsers() ([]models.User, error)
}

type userService struct{}

func NewUserService() UserService {
	return &userService{}
}

func (s *userService) GetUsers() ([]models.User, error) {
	var users []models.User
	if err := config.DB.Select("id, username, role").Find(&users).Error; err != nil {
		return nil, err
	}
	return users, nil
}
