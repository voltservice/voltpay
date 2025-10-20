package function

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"
	_ "voltpay_go/internal/auth"
	_ "voltpay_go/internal/bootstrap"
	_ "voltpay_go/internal/config"
	"voltpay_go/internal/handlers"
	"voltpay_go/internal/middleware"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"github.com/go-chi/chi/v5"
	chimid "github.com/go-chi/chi/v5/middleware"
	"github.com/joho/godotenv"
	"github.com/redis/go-redis/v9"
)

func init() {
	_ = godotenv.Load(".env")

	r := chi.NewRouter()
	r.Use(chimid.RequestID, chimid.RealIP, chimid.Recoverer)
	r.Use(chimid.StripSlashes)
	r.Use(middleware.CORS)

	// --- Redis + rate limiter BEFORE any routes ---
	rdb := redis.NewClient(&redis.Options{
		Addr:     os.Getenv("REDIS_ADDR"),
		Password: "",
		DB:       0,
	})
	ctx, cancel := context.WithTimeout(context.Background(), 500*time.Millisecond)
	defer cancel()
	if err := rdb.Ping(ctx).Err(); err != nil {
		fmt.Println("[boot] Redis not reachable, running WITHOUT Redis rate limit:", err)
	} else {
		rl := middleware.NewRateLimiter(rdb, 30, time.Minute, 10)
		r.Use(rl.Middleware)
	}
	rateCache := handlers.NewRateCache(rdb, 60*time.Second, 5*time.Minute)

	// --- now define routes ---
	ids := strings.Split(os.Getenv("GOOGLE_OAUTH_CLIENT_IDS"), ",")
	issuer := os.Getenv("RISC_TEST_ISSUER")
	jwksURL := os.Getenv("RISC_TEST_JWKS")
	localEndPoint := os.Getenv("RISC_RECEIVER_URL")
	baseURL := os.Getenv("BASE_URL")

	var riscHandler http.HandlerFunc
	if issuer != "" && jwksURL != "" && localEndPoint != "" && baseURL != "" {
		riscHandler = handlers.RISCReceiverWithConfig(issuer, jwksURL, ids)
	} else {
		riscHandler = handlers.RISCReceiver(ids)
	}
	r.Post("/risc/receiver", riscHandler)

	quotes := handlers.QuoteDeps{
		HTTP:   &http.Client{Timeout: 10 * time.Second},
		APIKey: os.Getenv("EXCHANGE_RATE_API_KEY"),
		Cache:  rateCache,
	}

	r.Route("/api", func(api chi.Router) {
		api.Get("/health", handlers.Health)
		api.Get("/quotes", quotes.Handle)
		api.Get("/message", func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			_, _ = w.Write([]byte(`{"message":"Hello from VoltPay Go backend"}`))
		})
	})

	handlers.Mount(r, nil)
	r.NotFound(func(w http.ResponseWriter, req *http.Request) { http.NotFound(w, req) })

	functions.HTTP("api", r.ServeHTTP)
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	fmt.Println("[boot] Functions Framework will listen on PORT:", port)
}
