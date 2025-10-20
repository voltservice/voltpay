package bootstrap

import (
	"context"
	"os"
	"sync"
	authsvc "voltpay_go/internal/auth"
	"voltpay_go/internal/config"
)

var (
	once    sync.Once
	global  *authsvc.Deps
	initErr error
)

// Deps returns initialized deps (Auth, Firestore) once per process.
func Deps(ctx context.Context) (*authsvc.Deps, error) {
	once.Do(func() {
		// Ensure project id is available (Cloud Run/Functions use GOOGLE_CLOUD_PROJECT)
		if os.Getenv("GCP_PROJECT") == "" && os.Getenv("GOOGLE_CLOUD_PROJECT") != "" {
			_ = os.Setenv("GCP_PROJECT", os.Getenv("GOOGLE_CLOUD_PROJECT"))
		}
		cfg := config.Load()
		global, initErr = authsvc.Init(ctx, cfg)
	})
	return global, initErr
}
