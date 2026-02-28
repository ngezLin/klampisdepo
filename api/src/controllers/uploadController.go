package controllers

import (
	"encoding/base64"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

type Base64UploadRequest struct {
	Image string `json:"image"`
}

// UploadImage handles image uploads (multipart/form-data or base64 JSON)
func UploadImage(c *gin.Context) {
	// Make sure the uploads directory exists
	uploadPath := "uploads"
	if err := os.MkdirAll(uploadPath, os.ModePerm); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create upload directory"})
		return
	}

	contentTypeHeader := c.GetHeader("Content-Type")

	// --- PATH 1: JSON containing Base64 String ---
	if strings.Contains(contentTypeHeader, "application/json") {
		var req Base64UploadRequest
		if err := c.ShouldBindJSON(&req); err != nil || req.Image == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON or missing 'image' field (base64 string)"})
			return
		}

		// Remove the 'data:image/...;base64,' prefix if it exists
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

		contentType := http.DetectContentType(decodedBytes)
		extension := ".jpg"
		if contentType == "image/png" {
			extension = ".png"
		} else if contentType == "image/webp" {
			extension = ".webp"
		} else if contentType == "image/gif" {
			extension = ".gif"
		} else if contentType != "image/jpeg" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid base64 file type. Only JPEG, PNG, WEBP, and GIF are allowed"})
			return
		}

		newFileName := fmt.Sprintf("img_%d%s", time.Now().UnixNano(), extension)
		newFilePath := filepath.Join(uploadPath, newFileName)

		if err := os.WriteFile(newFilePath, decodedBytes, 0644); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
			return
		}

		fileURL := fmt.Sprintf("/uploads/%s", newFileName)
		c.JSON(http.StatusOK, gin.H{
			"message": "Base64 file uploaded successfully",
			"url":     fileURL,
		})
		return
	}

	// --- PATH 2: Standard multipart/form-data File Upload ---
	file, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No image uploaded. Make sure to send file as 'image'"})
		return
	}

	// Validate file size (Max 5MB)
	if file.Size > 5<<20 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File too large (max 5MB)"})
		return
	}

	// Validate MIME type (magic bytes checking)
	openedFile, err := file.Open()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to open uploaded file"})
		return
	}
	defer openedFile.Close()

	// Read first 512 bytes for content type detection
	buffer := make([]byte, 512)
	if _, err := openedFile.Read(buffer); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to read file content"})
		return
	}
	
	contentType := http.DetectContentType(buffer)
	if contentType != "image/jpeg" && contentType != "image/png" && contentType != "image/webp" && contentType != "image/gif" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid file type. Only JPEG, PNG, WEBP, and GIF are allowed"})
		return
	}


	// Create a unique filename to prevent overwrites
	extension := filepath.Ext(file.Filename)
	if extension == "" {
		// Default to .jpg since frontend compressor typically outputs jpeg or webp
		extension = ".jpg"
	}
	
	newFileName := fmt.Sprintf("img_%d%s", time.Now().UnixNano(), extension)
	newFilePath := filepath.Join(uploadPath, newFileName)

	// Save the original multipart file to disk
	if err := c.SaveUploadedFile(file, newFilePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}

	// Construct public URL
	fileURL := fmt.Sprintf("/uploads/%s", newFileName)

	c.JSON(http.StatusOK, gin.H{
		"message": "File uploaded successfully",
		"url":     fileURL,
	})
}
