package controllers

import (
	"encoding/base64"
	"net/http"

	"kd-api/src/config"
	"kd-api/src/models"

	"github.com/gin-gonic/gin"
)

// ServeImage fetches an image from the database and serves it
func ServeImage(c *gin.Context) {
	filename := c.Param("filename")

	var image models.Image
	if err := config.DB.Where("file_name = ?", filename).First(&image).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Image not found"})
		return
	}

	decodedBytes, err := base64.StdEncoding.DecodeString(image.Data)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode image data"})
		return
	}

	c.Data(http.StatusOK, image.MimeType, decodedBytes)
}
