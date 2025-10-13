package main

import (
	"log"
	"os"
	_ "voltpay_go"

	"github.com/GoogleCloudPlatform/functions-framework-go/funcframework"
)

func main() {
	// Ensure FUNCTION_TARGET matches what you registered: "api"
	if os.Getenv("FUNCTION_TARGET") == "" {
		_ = os.Setenv("FUNCTION_TARGET", "api")
	}
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("Starting Functions Framework on port %s (FUNCTION_TARGET=%s)", port, os.Getenv("FUNCTION_TARGET"))
	if err := funcframework.Start(port); err != nil {
		log.Fatalf("funcframework.Start: %v", err)
	}
}
