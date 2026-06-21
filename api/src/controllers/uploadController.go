package controllers

import (
	"encoding/base64"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"kd-api/src/config"
	"kd-api/src/models"

	"github.com/gin-gonic/gin"
)

type Base64UploadRequest struct {
	Image string `json:"image"`
}

// UploadImage handles image uploads (multipart/form-data or base64 JSON) and saves to DB
func UploadImage(c *gin.Context) {
	contentTypeHeader := c.GetHeader("Content-Type")

	var finalBase64 string
	var finalMimeType string
	var extension string

	// --- PATH 1: JSON containing Base64 String ---
	if strings.Contains(contentTypeHeader, "application/json") {
		var req Base64UploadRequest
		if err := c.ShouldBindJSON(&req); err != nil || req.Image == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON or missing 'image' field (base64 string)"})
			return
		}

		base64Data := req.Image
		if idx := strings.Index(base64Data, ","); idx != -1 {
			base64Data = base64Data[idx+1:]
		}

		decodedBytes, err := base64.StdEncoding.DecodeString(base64Data)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Failed to decode base64 image"})
			return
		}

		if len(decodedBytes) > 5<<20 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "File too large (max 5MB)"})
			return
		}

		finalMimeType = http.DetectContentType(decodedBytes)
		finalBase64 = base64Data
	} else {
		// --- PATH 2: Standard multipart/form-data File Upload ---
		file, err := c.FormFile("image")
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "No image uploaded. Make sure to send file as 'image'"})
			return
		}

		if file.Size > 5<<20 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "File too large (max 5MB)"})
			return
		}

		openedFile, err := file.Open()
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to open uploaded file"})
			return
		}
		defer openedFile.Close()

		fileBytes, err := io.ReadAll(openedFile)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read file content"})
			return
		}

		finalMimeType = http.DetectContentType(fileBytes)
		finalBase64 = base64.StdEncoding.EncodeToString(fileBytes)
	}

	// Validate MIME type and set extension
	if finalMimeType == "image/png" {
		extension = ".png"
	} else if finalMimeType == "image/webp" {
		extension = ".webp"
	} else if finalMimeType == "image/gif" {
		extension = ".gif"
	} else if finalMimeType == "image/jpeg" {
		extension = ".jpg"
	} else {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file type. Only JPEG, PNG, WEBP, and GIF are allowed"})
		return
	}

	newFileName := fmt.Sprintf("img_%d%s", time.Now().UnixNano(), extension)

	// Save to Database
	imageRecord := models.Image{
		FileName: newFileName,
		Data:     finalBase64,
		MimeType: finalMimeType,
	}

	if err := config.DB.Create(&imageRecord).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save image to database"})
		return
	}

	// Return new /images/ URL
	fileURL := fmt.Sprintf("/images/%s", newFileName)
	c.JSON(http.StatusOK, gin.H{
		"message": "File uploaded successfully to database",
		"url":     fileURL,
	})
}
