package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strings"
	"time"

	"github.com/go-chi/chi/v5/middleware"
	"github.com/lestrrat-go/jwx/v2/jwk"
	"github.com/lestrrat-go/jwx/v2/jwt"
)

const (
	googleIssuer = "https://accounts.google.com"
	googleJWKS   = "https://www.googleapis.com/oauth2/v3/certs"
)

// RISCReceiverWithConfig allows you to override issuer/JWKS (useful for local tests).
func RISCReceiverWithConfig(issuer string, jwksURL string, allowedAUDs []string) http.HandlerFunc {
	fmt.Println("[cap] issuer:", issuer)
	fmt.Println("[cap] jwks:", jwksURL)
	fmt.Println("[cap] allowed audiences:", allowedAUDs)
	httpClient := &http.Client{Timeout: 5 * time.Second}

	allowed := make(map[string]struct{}, len(allowedAUDs))
	for _, a := range allowedAUDs {
		if a = strings.TrimSpace(a); a != "" {
			allowed[a] = struct{}{}
		}
	}

	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()

		raw, err := extractTokenFromBody(r.Body)
		if err != nil || raw == "" {
			http.Error(w, "missing token", http.StatusBadRequest)
			return
		}

		// Fetch JWKS now; if it fails, return 503 instead of panicking
		keyset, err := jwk.Fetch(ctx, jwksURL, jwk.WithHTTPClient(httpClient))
		if err != nil || keyset == nil || keyset.Len() == 0 {
			http.Error(w, "jwks unavailable", http.StatusServiceUnavailable)
			return
		}

		// Parse & verify JWT using the JWKS and issuer
		tok, err := jwt.Parse(
			[]byte(raw),
			jwt.WithKeySet(keyset), // <- correct usage; no WithVerifyAuto
			jwt.WithIssuer(issuer),
			jwt.WithAcceptableSkew(5*time.Second), // allow small clock skew
		)
		if err != nil {
			// TEMP DEBUG: return the real reason
			http.Error(w, "invalid token: "+err.Error(), http.StatusBadRequest)
			// and log it server-side, too
			fmt.Println("[risc] parse/verify error:", err)
			return
		}

		// Audience check (iterate values, not indices!)
		okAud := false
		for _, aud := range tok.Audience() {
			if _, ok := allowed[aud]; ok {
				okAud = true
				break
			}
		}
		if !okAud {
			http.Error(w, "aud mismatch", http.StatusBadRequest)
			return
		}

		// Subject (Google "sub") or nested subject identifier
		sub := tok.Subject()
		if sub == "" {
			if s, _ := getString(tok, "subject", "identifier", "value"); s != "" {
				sub = s
			}
		}
		email, _ := getString(tok, "email") // optional

		userID := resolveLocalUserID(ctx, sub, email)
		if userID == "" {
			// Still return 204 so Google doesn't retry, but you can log req id
			_ = middleware.GetReqID(ctx)
			w.WriteHeader(http.StatusNoContent)
			return
		}

		events, ok := tok.PrivateClaims()["events"].(map[string]any)
		if !ok || len(events) == 0 {
			w.WriteHeader(http.StatusNoContent)
			return
		}

		for eventType, body := range events {
			_ = handleRISCEvent(ctx, userID, eventType, body)
		}

		w.WriteHeader(http.StatusNoContent)
	}
}

// RISCReceiver Production-default receiver (Google issuer + JWKS)
func RISCReceiver(allowedAUDs []string) http.HandlerFunc {
	return RISCReceiverWithConfig(googleIssuer, googleJWKS, allowedAUDs)
}

// --- helpers ---

func extractTokenFromBody(rc io.ReadCloser) (string, error) {
	defer func(rc io.ReadCloser) {
		err := rc.Close()
		if err != nil {

		}
	}(rc)
	b, err := io.ReadAll(rc)
	if err != nil {
		return "", err
	}
	raw := strings.TrimSpace(string(b))
	if raw == "" {
		return "", errors.New("empty body")
	}
	// accept either raw JWT or JSON {token|jwt|security_event_token}
	if strings.HasPrefix(raw, "{") {
		var m map[string]any
		if err := json.Unmarshal(b, &m); err != nil {
			return "", err
		}
		for _, k := range []string{"token", "jwt", "security_event_token"} {
			if v, ok := m[k].(string); ok && v != "" {
				return v, nil
			}
		}
		return "", errors.New("no token field")
	}
	return raw, nil
}

func getString(tok jwt.Token, keys ...string) (string, bool) {
	claim := tok.PrivateClaims()
	var cur any = claim
	for _, k := range keys {
		m, ok := cur.(map[string]any)
		if !ok {
			return "", false
		}
		cur, ok = m[k]
		if !ok {
			return "", false
		}
	}
	s, ok := cur.(string)
	return s, ok
}

// Decide what to do per event type
func handleRISCEvent(ctx context.Context, userID string, eventType string, body any) error {
	switch eventType {
	case "https://schemas.openid.net/secevent/risc/event-type/credentials-changed",
		"https://schemas.openid.net/secevent/risc/event-type/account-disabled",
		"https://schemas.openid.net/secevent/risc/event-type/sessions-revoked":
		if err := MarkUserHighRisk(ctx, userID); err != nil {
			return err
		}
		if err := KillSessions(ctx, userID); err != nil {
			return err
		}
	default:
		// log for visibility if you like
	}
	return nil
}

// ---- stubs: implement in your codebase ----

func resolveLocalUserID(ctx context.Context, googleSub string, email string) string {
	return "" // TODO
}

func MarkUserHighRisk(ctx context.Context, userID string) error { return nil }
func KillSessions(ctx context.Context, userID string) error     { return nil }
