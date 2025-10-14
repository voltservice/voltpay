package handlers

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"voltpay_go/internal/risc"
)

// ---- Public API ------------------------------------------------------------

// RISCReceiver returns an http.HandlerFunc that accepts Google CAP (RISC) SETs,
// using Google's discovery document to find the JWKS URI.
func RISCReceiver(clientIDs []string) http.HandlerFunc {
	jwksURL, err := discoverCAPJWKS(context.Background())
	if err != nil {
		// Fallback to the well-known stable JWKS path if discovery fails.
		log.Printf("[RISC] discovery failed (%v); falling back to default JWKS URL", err)
		jwksURL = "https://www.googleapis.com/oauth2/v3/certs"
	}
	return newRISCHandler(jwksURL, clientIDs)
}

// RISCReceiverWithConfig lets you plug a custom issuer/JWKS (useful for tests).
// NOTE: The verifier in risc.NewReceiver enforces Google's issuer
// (https://accounts.google.com). The custom issuer is logged but not enforced here.
func RISCReceiverWithConfig(issuer, jwksURL string, clientIDs []string) http.HandlerFunc {
	if issuer != "" {
		log.Printf("[RISC] (with-config) issuer hint = %s (verifier still expects https://accounts.google.com)", issuer)
	}
	if jwksURL == "" {
		u, err := discoverCAPJWKS(context.Background())
		if err == nil {
			jwksURL = u
		} else {
			jwksURL = "https://www.googleapis.com/oauth2/v3/certs"
		}
	}
	return newRISCHandler(jwksURL, clientIDs)
}

// ---- Internal wiring -------------------------------------------------------

func newRISCHandler(jwksURL string, clientIDs []string) http.HandlerFunc {
	httpClient := &http.Client{Timeout: 8 * time.Second}
	kp := &risc.GoogleJWKS{
		JWKSURL: jwksURL,
		HTTP:    httpClient,
	}
	log.Printf("[RISC] using JWKS: %s", jwksURL)

	mitigator := &risc.NoopMitigator{Logger: log.Default()}

	issuer := os.Getenv("RISC_TEST_ISSUER")
	if issuer == "" {
		log.Printf("[RISC] TEST issuer active: %s", issuer)
		return risc.NewReceiverWithIssuer(kp, clientIDs, issuer, func(ctx context.Context, claims *risc.Claims) error {
			log.Printf("[RISC] TEST issuer: %s", issuer)
			return handleEvents(ctx, mitigator, claims.RawEvents(), claims.Subject())
		})
	}

	// Handle function maps incoming RISC events to mitigation actions.
	// Bridge risc.NewReceiver (expects its own claims type) via a tiny adapter.
	return risc.NewReceiver(kp, clientIDs, func(ctx context.Context, claims *risc.Claims) error {
		return handleEvents(ctx, mitigator, claims.Events, claims.Subject())
	})
}

// ---- Discovery -------------------------------------------------------------

// Google CAP discovery doc: https://accounts.google.com/.well-known/risc-configuration
// We only need the jwks_uri.
func discoverCAPJWKS(ctx context.Context) (string, error) {
	req, _ := http.NewRequestWithContext(ctx, "GET", "https://accounts.google.com/.well-known/risc-configuration", nil)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return "", err
	}
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {

		}
	}(resp.Body)
	if resp.StatusCode/100 != 2 {
		return "", errors.New("non-2xx discovery response")
	}
	var disc struct {
		JWKSURI string `json:"jwks_uri"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&disc); err != nil {
		return "", err
	}
	if disc.JWKSURI == "" {
		return "", errors.New("empty jwks_uri in discovery")
	}
	return disc.JWKSURI, nil
}

// ---- Event handling (maps CAP events to mitigations) -----------------------

func handleEvents(ctx context.Context, m risc.Mitigator, events map[string]any, subject string) error {
	// Google RISC event types we care about.
	const (
		evAccountDisabled          = "https://schemas.openid.net/secevent/risc/event-type/account-disabled"
		evAccountEnabled           = "https://schemas.openid.net/secevent/risc/event-type/account-enabled"
		evCredentialChangeRequired = "https://schemas.openid.net/secevent/risc/event-type/account-credential-change-required"
		evVerification             = "https://schemas.openid.net/secevent/risc/event-type/verification"
	)

	uid := subject
	// Best-effort: if subject not set, try to pull something from the event body
	// (providers differ; keep this lenient).
	if uid == "" {
		if s := findSubjectInEvents(events); s != "" {
			uid = s
		}
	}

	for et := range events {
		switch et {
		case evVerification:
			// Verification probe from Google—nothing to do, just ack (204 is returned by caller).
			log.Printf("[RISC] verification event ok (sub=%s)", uid)

		case evAccountDisabled:
			log.Printf("[RISC] account-disabled (sub=%s) -> MarkHighRisk + KillSessions", uid)
			_ = m.MarkHighRisk(ctx, uid)
			_ = m.KillSessions(ctx, uid)

		case evAccountEnabled:
			// You might want to lower the risk flag, or simply log.
			log.Printf("[RISC] account-enabled (sub=%s)", uid)

		case evCredentialChangeRequired:
			log.Printf("[RISC] credential-change-required (sub=%s) -> MarkHighRisk + KillSessions", uid)
			_ = m.MarkHighRisk(ctx, uid)
			_ = m.KillSessions(ctx, uid)

		default:
			// Unknown/less common events—log only for now.
			log.Printf("[RISC] unhandled event: %s (sub=%s)", et, uid)
		}
	}
	return nil
}

// Pull a "subject" from event payloads if not present at top-level claims.
func findSubjectInEvents(events map[string]any) string {
	type subj struct {
		Subject string `json:"subject"`
		Sub     string `json:"sub"`
		Email   string `json:"email"`
	}
	for _, v := range events {
		// expect each v to be an object; marshal/unmarshal to inspect loosely
		b, _ := json.Marshal(v)
		var s subj
		if err := json.Unmarshal(b, &s); err == nil {
			if s.Subject != "" {
				return s.Subject
			}
			if s.Sub != "" {
				return s.Sub
			}
			if s.Email != "" {
				return s.Email
			}
		}
	}
	return ""
}
