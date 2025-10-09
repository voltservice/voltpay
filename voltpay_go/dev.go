package function

import (
    "os"
    "time"
    "net/http"

    "github.com/go-chi/chi/v5"

    "github.com/GoogleCloudPlatform/functions-framework-go/functions"
    "voltpay_go/internal/handlers"
    "voltpay_go/internal/middleware"
)

func init() {
    r := chi.NewRouter()
    r.Use(middleware.CORS)

    r.Get("/api/health", handlers.Health)

    quotes := handlers.QuoteDeps{
        HTTP:   &http.Client{Timeout: 10 * time.Second},
        APIKey: os.Getenv("EXCHANGE_RATE_API_KEY"),
    }
    r.Get("/api/quotes", quotes.Handle)

    r.Get("/api/message", func(w http.ResponseWriter, r *http.Request) {
        w.Header().Set("Content-Type", "application/json")
        w.WriteHeader(http.StatusOK)
        w.Write([]byte(`{"message":"Hello from VoltPay Go backend"}`))
    })

    // Register this as the "api" function
    functions.HTTP("api", r.ServeHTTP)
}
