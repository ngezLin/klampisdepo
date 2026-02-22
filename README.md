# Klampis Depo

This repository contains both the Go API backend and the React frontend for the Klampis Depo application.

## Prerequisites

- Node.js (v16+)
- Go (v1.20+)

## Getting Started

1. **Install dependencies:**
   ```bash
   npm run install:all
   ```
2. **Setup environment variables:**
   - Create a `.env` file in the `api` folder based on `api/.env.example` (if applicable).

3. **Run the full stack application:**
   ```bash
   npm start
   ```
   This will simultaneously start the Go API backend and the React development server using `concurrently`.
