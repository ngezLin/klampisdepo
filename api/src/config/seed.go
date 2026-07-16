package config

import (
	"fmt"
	"os"

	"kd-api/src/models"

	"golang.org/x/crypto/bcrypt"
	"gorm.io/gorm"
)

// SeedTestUser creates a test user for CI/CD E2E tests.
// Only activates when the SEED_TEST_USER env var is set to "true".
// Reads TEST_USERNAME and TEST_PASSWORD from env vars.
func SeedTestUser(db *gorm.DB) {
	if os.Getenv("SEED_TEST_USER") != "true" {
		return
	}

	testUser := os.Getenv("TEST_USERNAME")
	testPass := os.Getenv("TEST_PASSWORD")
	if testUser == "" || testPass == "" {
		fmt.Println("⚠️  SEED_TEST_USER is set but TEST_USERNAME or TEST_PASSWORD is empty")
		return
	}

	hashedPassword, err := bcrypt.GenerateFromPassword([]byte(testPass), bcrypt.DefaultCost)
	if err != nil {
		fmt.Println("❌ Failed to hash test password:", err)
		return
	}

	user := models.User{
		Username: testUser,
		Password: string(hashedPassword),
		Role:     "owner",
	}

	result := db.Where("username = ?", testUser).FirstOrCreate(&user)
	if result.Error != nil {
		fmt.Println("❌ Failed to seed test user:", result.Error)
		return
	}

	fmt.Printf("🧪 Test user '%s' seeded (role: owner)\n", testUser)
}
