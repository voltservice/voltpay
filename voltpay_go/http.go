package function

import (
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
	"github.com/go-chi/chi/v5"
	chimid "github.com/go-chi/chi/v5/middleware"
	"github.com/joho/godotenv"

	"voltpay_go/internal/handlers"
	"voltpay_go/internal/middleware"
)

func init() {
	_ = godotenv.Load(".env")
	r := chi.NewRouter()
	r.Use(chimid.RequestID, chimid.RealIP, chimid.Recoverer)
	r.Use(chimid.StripSlashes)
	r.Use(middleware.CORS)

	// Cross-Account Protection / RISC receiver
	// Comma-separated Google OAuth client IDs (web/android/ios)
	ids := strings.Split(os.Getenv("GOOGLE_OAUTH_CLIENT_IDS"), ",")
	fmt.Println("Loaded CAP client IDs:", ids)

	issuer := os.Getenv("RISC_TEST_ISSUER")
	jwksURL := os.Getenv("RISC_TEST_JWKS")
	localEndPoint := os.Getenv("RISC_RECEIVER_URL")
	
	var riscHandler http.HandlerFunc
	if issuer != "" && jwksURL != "" && localEndPoint != "" {
		fmt.Println("[boot] Using TEST issuer/JWKS:", issuer, jwksURL, localEndPoint)
		riscHandler = handlers.RISCReceiverWithConfig(issuer, jwksURL, ids)
	} else {
		fmt.Println("[boot] Using GOOGLE issuer/JWKS defaults")
		riscHandler = handlers.RISCReceiver(ids)
	}

	r.Post("/risc/receiver", riscHandler)

	quotes := handlers.QuoteDeps{
		HTTP:   &http.Client{Timeout: 10 * time.Second},
		APIKey: os.Getenv("EXCHANGE_RATE_API_KEY"),
	}

	r.Route("/api", func(api chi.Router) {
		api.Get("/health", handlers.Health)
		api.Get("/quotes", quotes.Handle)
		api.Get("/message", func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Content-Type", "application/json")
			w.WriteHeader(http.StatusOK)
			_, err := w.Write([]byte(`{"message":"Hello from VoltPay Go backend"}`))
			if err != nil {
				return
			}
		})
	})

	// (Debug) log unmatched paths
	r.NotFound(func(w http.ResponseWriter, req *http.Request) {
		http.NotFound(w, req)
	})

	functions.HTTP("api", r.ServeHTTP)

	// Helpful boot log: Functions Framework uses PORT
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	fmt.Println("[boot] Functions Framework will listen on PORT:", port)
}
