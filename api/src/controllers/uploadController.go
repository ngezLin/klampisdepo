package controllers

import (
	"fmt"
	"net/http"
	"os"
	"path/filepath"
	"time"

	"github.com/gin-gonic/gin"
)

// UploadImage handles image uploads from the frontend
func UploadImage(c *gin.Context) {
	// Parse the multipart form
	file, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No image uploaded. Make sure to send file as 'image'"})
		return
	}

	// Validate file size (Max 5MB to be safe, though frontend compresses it)
	if file.Size > 5<<20 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "File too large (max 5MB)"})
		return
	}

	// Make sure the uploads directory exists
	uploadPath := "uploads"
	if err := os.MkdirAll(uploadPath, os.ModePerm); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to create upload directory"})
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

	// Save the file to disk
	if err := c.SaveUploadedFile(file, newFilePath); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to save file"})
		return
	}

	// Construct public URL. We serve the /uploads directory statically at /uploads
	// Using a relative path makes it easier to work with environments (dev vs prod)
	fileURL := fmt.Sprintf("/uploads/%s", newFileName)

	c.JSON(http.StatusOK, gin.H{
		"message": "File uploaded successfully",
		"url":     fileURL,
	})
}
