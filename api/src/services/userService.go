package services

import (
	"errors"
	"kd-api/src/config"
	"kd-api/src/dtos"
	"kd-api/src/models"

	"golang.org/x/crypto/bcrypt"
)

type UserService interface {
	GetUsers() ([]models.User, error)
	CreateUser(input dtos.CreateUserInput) (models.User, error)
	UpdateUser(id string, input dtos.UpdateUserInput) (models.User, error)
	DeleteUser(id string) error
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

func (s *userService) CreateUser(input dtos.CreateUserInput) (models.User, error) {
	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
	if err != nil {
		return models.User{}, err
	}

	user := models.User{
		Username: input.Username,
		Password: string(hashedPassword),
		Role:     input.Role,
	}

	if err := config.DB.Create(&user).Error; err != nil {
		return models.User{}, errors.New("failed to create user, username might exist")
	}

	user.Password = "" // Hide password from response
	return user, nil
}

func (s *userService) UpdateUser(id string, input dtos.UpdateUserInput) (models.User, error) {
	var user models.User
	if err := config.DB.First(&user, id).Error; err != nil {
		return models.User{}, errors.New("user not found")
	}

	if input.Username != "" {
		user.Username = input.Username
	}
	if input.Role != "" {
		user.Role = input.Role
	}
	if input.Password != "" {
		hashedPassword, err := bcrypt.GenerateFromPassword([]byte(input.Password), bcrypt.DefaultCost)
		if err != nil {
			return models.User{}, err
		}
		user.Password = string(hashedPassword)
	}

	if err := config.DB.Save(&user).Error; err != nil {
		return models.User{}, err
	}

	user.Password = "" // Hide password from response
	return user, nil
}

func (s *userService) DeleteUser(id string) error {
	if err := config.DB.Delete(&models.User{}, id).Error; err != nil {
		return err
	}
	return nil
}
