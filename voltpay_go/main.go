// main.go
package main

import (
	"fmt"
	"net/http"

	"github.com/go-chi/chi/v5"
)

func main() {
	r := chi.NewRouter()

	// Simple health check route
	r.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("🚀 Voltpay Go API is running"))
	})

	r.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Access-Control-Allow-Origin", "*")
			w.Header().Set("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
			w.Header().Set("Access-Control-Allow-Headers", "Content-Type")
			if r.Method == "OPTIONS" {
				return
			}
			next.ServeHTTP(w, r)
		})
	})

	// Example route for mobile integration
	r.Get("/api/message", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte(`{"message": "Hello from MetalBrain Go backend"}`))
	})

	fmt.Println("✅ Server running on http://localhost:8081")
	http.ListenAndServe(":8081", r)
}
