package main

import (
	"log"
	"net/http"
	"time"
	"os"

	"github.com/go-chi/chi/v5"
	"voltpay_go/internal/handlers"
	"voltpay_go/internal/middleware"
)

func main() {
	r := chi.NewRouter()
	r.Use(middleware.CORS)

	r.Get("/api/health", handlers.Health)


    quotes := handlers.QuoteDeps{
        HTTP:   &http.Client{Timeout: 10 * time.Second},
        APIKey: os.Getenv("EXCHANGE_RATE_API_KEY"),
    }
    r.Get("/api/quotes", quotes.Handle)

	// if your quotes handler needs deps, wire them here similarly
	r.Get("/api/message", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusOK)
        w.Write([]byte(`{"message":"Hello from MetalBrain Go backend"}`))
    })

	log.Println("listening on :9099")
	log.Fatal(http.ListenAndServe(":9099", r))
}
