package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"
	"voltpay_go/internal/bootstrap"

	"voltpay_go/internal/auth"
	"voltpay_go/internal/httpx"
)

// BeforeCreate POST /auth/beforeCreate
func BeforeCreate(deps *auth.Deps) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodOptions {
			httpx.CORS(w)
			w.WriteHeader(http.StatusNoContent)
			return
		}
		start := time.Now()

		// LAZY INIT: if deps were passed as nil from Mount(), resolve once here
		if deps == nil || deps.Cfg == nil {
			var err error
			deps, err = bootstrap.Deps(r.Context())
			if err != nil {
				httpx.Deny(w, 500, "internal", "bootstrap failed: "+err.Error())
				return
			}
			if deps == nil || deps.Cfg == nil {
				httpx.Deny(w, 500, "internal", "missing configuration")
				return
			}
		}

		var body beforeBody
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			httpx.Deny(w, 400, "invalid-argument", "Bad JSON")
			return
		}
		user := getUserMap(beforeBody{})
		provider := detectProvider(body.EventType, body.Data, user)

		if len(user) == 0 || provider == "anonymous" || provider == "phone" || provider == "email" {
			httpx.JSON(w, 200, map[string]any{
				"userRecord": map[string]any{"customClaims": map[string]any{"role": "guest"}},
			})
			return
		}

		if len(deps.Cfg.AllowedTenants) > 0 {
			if _, ok := deps.Cfg.AllowedTenants[body.Resource]; !ok {
				httpx.Deny(w, 403, "permission-denied", "Tenant not allowed.")
				return
			}
		}
		if len(deps.Cfg.AllowedProviders) > 0 && provider != "" {
			if _, ok := deps.Cfg.AllowedProviders[provider]; !ok {
				httpx.Deny(w, 403, "permission-denied", fmt.Sprintf("Provider '%s' not allowed for sign up.", provider))
				return
			}
		}
		if provider == "" {
			httpx.Deny(w, 400, "invalid-argument", "Could not determine identity provider.")
			return
		}

		// Email checks for non-federated
		if provider == "password" || provider == "emaillink" || provider == "email" {
			rawEmail, _ := user["email"].(string)
			email, domain := splitEmail(rawEmail)
			if email == "" {
				httpx.Deny(w, 400, "invalid-argument", "Email is arequired for email/password sign up.")
				return
			}
			if _, blocked := deps.Cfg.BlockedEmails[email]; blocked {
				httpx.Deny(w, 403, "permission-denied", "Email is blocked.")
				return
			}
			if isDisposable(deps.Cfg, email) {
				httpx.Deny(w, 422, "invalid-argument", "Disposable email addresses are not allowed.")
				return
			}
			if len(deps.Cfg.AllowedEmailDomains) > 0 {
				if _, ok := deps.Cfg.AllowedEmailDomains[domain]; !ok {
					httpx.Deny(w, 403, "permission-denied", fmt.Sprintf("Domain '%s' is not allowed.", domain))
					return
				}
			}
		}

		updates := map[string]any{
			"displayName":  user["displayName"],
			"customClaims": map[string]any{"role": "user"},
		}

		if time.Since(start) > 6500*time.Millisecond {
			httpx.Deny(w, 503, "deadline-exceeded", "Sign up check took too long.")
			return
		}
		httpx.JSON(w, 200, map[string]any{"userRecord": updates})
	}
}

// BeforeSignIn POST /auth/beforeSignIn
func BeforeSignIn() http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if r.Method == http.MethodOptions {
			httpx.CORS(w)
			w.WriteHeader(http.StatusNoContent)
			return
		}
		var body beforeBody
		if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
			httpx.Deny(w, 400, "invalid-argument", "Bad JSON")
			return
		}
		user := getUserMap(beforeBody{})
		provider := detectProvider(body.EventType, body.Data, user)

		if len(user) == 0 || provider == "phone" || provider == "anonymous" || provider == "emaillink" || provider == "email" {
			httpx.JSON(w, 200, map[string]any{"sessionClaims": map[string]any{"ts": time.Now().Unix()}})
			return
		}
		if provider == "password" {
			if v, _ := user["emailVerified"].(bool); !v {
				httpx.Deny(w, 412, "failed-precondition", "Please verify your email before signing in.")
				return
			}
		}
		httpx.JSON(w, 200, map[string]any{"sessionClaims": map[string]any{"ts": time.Now().Unix()}})
	}
}
