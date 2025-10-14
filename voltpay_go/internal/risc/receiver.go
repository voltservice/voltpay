package risc

import (
	"context"
	"crypto/rsa"
	"encoding/json"
	"errors"
	"io"
	"net/http"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

// Claims Minimal fields we care about from Google's SET
type Claims struct {
	Iss    string         `json:"iss"`
	Aud    interface{}    `json:"aud"` // string or []string
	Iat    int64          `json:"iat,omitempty"`
	Jti    string         `json:"jti,omitempty"`
	Events map[string]any `json:"events"`
	Sub    string         `json:"sub,omitempty"`
	jwt.RegisteredClaims
}

func (c *Claims) Subject() string {
	return c.Sub
}

func (c *Claims) RawEvents() map[string]any {
	return c.Events
}

// KeyProvider JWKS cache
type KeyProvider interface {
	Keyfunc(ctx context.Context, keyID string) (any, error)
}

func NewReceiver(kp KeyProvider, clientIDs []string, handle func(ctx context.Context, claims *Claims) error) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		raw, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "read", http.StatusBadRequest)
			return
		}
		tokenStr := string(raw)

		keyfunc := func(t *jwt.Token) (any, error) {
			kid, _ := t.Header["kid"].(string)
			if kid == "" {
				return nil, errors.New("missing kid")
			}
			return kp.Keyfunc(ctx, kid)
		}

		var claims Claims
		tok, err := jwt.ParseWithClaims(tokenStr, &claims, keyfunc,
			jwt.WithValidMethods([]string{"RS256"}),
			jwt.WithIssuer("https://accounts.google.com"))
		if err != nil || !tok.Valid {
			http.Error(w, "invalid", http.StatusBadRequest)
			return
		}

		// aud must match one of your OAuth client IDs
		if !audMatches(claims.Aud, clientIDs) {
			http.Error(w, "bad aud", http.StatusBadRequest)
			return
		}

		// Process asynchronously if your work is heavy.
		if err := handle(ctx, &claims); err != nil {
			http.Error(w, "handler", http.StatusInternalServerError)
			return
		}

		// Per spec, respond 204 quickly.
		w.WriteHeader(http.StatusNoContent)
	}
}

func NewReceiverWithIssuer(
	kp KeyProvider,
	clientIDs []string,
	issuer string,
	handle func(ctx context.Context, claims *Claims) error,
) http.HandlerFunc {
	if issuer == "" {
		issuer = "https://accounts.google.com"
	}
	return func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		defer func(Body io.ReadCloser) {
			err := Body.Close()
			if err != nil {

			}
		}(r.Body)

		raw, err := io.ReadAll(r.Body)
		if err != nil {
			http.Error(w, "read", http.StatusBadRequest)
			return
		}
		tokenStr := string(raw)

		keyfunc := func(t *jwt.Token) (any, error) {
			kid, _ := t.Header["kid"].(string)
			if kid == "" {
				return nil, errors.New("missing kid")
			}
			return kp.Keyfunc(ctx, kid)
		}

		var mc jwt.MapClaims
		tok, err := jwt.ParseWithClaims(tokenStr, &mc, keyfunc,
			jwt.WithValidMethods([]string{"RS256"}),
			jwt.WithIssuer(issuer),
		)
		if err != nil || !tok.Valid {
			http.Error(w, "invalid", http.StatusBadRequest)
			return
		}

		claims := &Claims{
			Iss:    getString(mc["iss"]),
			Aud:    mc["aud"],
			Iat:    getInt64(mc["iat"]),
			Jti:    getString(mc["jti"]),
			Events: getMap(mc["events"]),
			Sub:    getString(mc["sub"]),
		}

		if !audMatches(claims.Aud, clientIDs) {
			http.Error(w, "bad aud", http.StatusBadRequest)
			return
		}
		if err := handle(ctx, claims); err != nil {
			http.Error(w, "handler", http.StatusInternalServerError)
			return
		}
		w.WriteHeader(http.StatusNoContent)
	}
}

func audMatches(aud interface{}, allowed []string) bool {
	switch v := aud.(type) {
	case string:
		for _, a := range allowed {
			if v == a {
				return true
			}
		}
	case []any:
		for _, e := range v {
			if s, ok := e.(string); ok {
				for _, a := range allowed {
					if s == a {
						return true
					}
				}
			}
		}
	}
	return false
}

// --- tiny helpers for lifting jwt.MapClaims into our Claims ---
func getString(v any) string {
	if s, ok := v.(string); ok {
		return s
	}
	return ""
}

func getInt64(v any) int64 {
	switch t := v.(type) {
	case float64:
		return int64(t)
	case json.Number:
		i, _ := t.Int64()
		return i
	default:
		return 0
	}
}

func getMap(v any) map[string]any {
	if m, ok := v.(map[string]any); ok {
		return m
	}
	return map[string]any{}
}

// GoogleJWKS --- Simple JWKS provider for Google's CAP keys ---
// RISC discovery: https://accounts.google.com/.well-known/risc-configuration
// Load its "jwks_uri" and refresh periodically.
type GoogleJWKS struct {
	JWKSURL string
	Cache   map[string]*rsa.PublicKey
	Last    time.Time
	HTTP    *http.Client
}

func (g *GoogleJWKS) Keyfunc(ctx context.Context, keyID string) (any, error) {
	if g.Cache == nil || time.Since(g.Last) > 15*time.Minute {
		req, _ := http.NewRequestWithContext(ctx, "GET", g.JWKSURL, nil)
		resp, err := g.HTTP.Do(req)
		if err != nil {
			return nil, err
		}
		defer func(Body io.ReadCloser) {
			err := Body.Close()
			if err != nil {

			}
		}(resp.Body)
		var jwks struct {
			Keys []struct {
				Kid string `json:"kid"`
				E   string `json:"e"`
				N   string `json:"n"`
				Kty string `json:"kty"`
			} `json:"keys"`
		}
		if err := json.NewDecoder(resp.Body).Decode(&jwks); err != nil {
			return nil, err
		}
		g.Cache = map[string]*rsa.PublicKey{}
		for _, k := range jwks.Keys {
			// Convert N,E (base64url) to rsa.PublicKey
			pub, err := jwkToRSAPub(k.N, k.E)
			if err == nil {
				g.Cache[k.Kid] = pub
			}
		}
		g.Last = time.Now()
	}
	if pk, ok := g.Cache[keyID]; ok {
		return pk, nil
	}
	return nil, errors.New("key not found")
}
