package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"cloud.google.com/go/firestore"
	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"

	authsvc "voltpay_go/internal/auth"
	"voltpay_go/internal/config"
	"voltpay_go/internal/handlers"
	"voltpay_go/internal/httpx"
)

func main() {
	ctx := context.Background()
	cfg := config.Load()

	deps, err := authsvc.Init(ctx, cfg)
	if err != nil {
		log.Fatalf("init firebase: %v", err)
	}
	defer func(Firestore *firestore.Client) {
		err := Firestore.Close()
		if err != nil {
			log.Fatalf("close Firestore: %v", err)
		}
	}(deps.Firestore)

	r := chi.NewRouter()
	r.Use(middleware.RequestID, middleware.RealIP, middleware.Logger, middleware.Recoverer)
	r.Use(func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, req *http.Request) {
			httpx.CORS(w)
			if req.Method == http.MethodOptions {
				w.WriteHeader(http.StatusNoContent)
				return
			}
			next.ServeHTTP(w, req)
		})
	})

	r.Get("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	})

	handlers.Mount(r, deps)

	addr := ":" + envOr("PORT", "8080")
	log.Printf("authgate listening on %s", addr)
	if err := http.ListenAndServe(addr, r); err != nil {
		log.Fatal(err)
	}
}

func envOr(k, d string) string {
	if v := os.Getenv(k); v != "" {
		return v
	}
	return d
}
