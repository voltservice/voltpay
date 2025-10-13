package main

import (
	"bytes"
	"io"
	"log"
	"net/http"
	"os"
	"time"

	"voltpay_go/internal/devkeys"

	"github.com/lestrrat-go/jwx/v2/jwa"
	"github.com/lestrrat-go/jwx/v2/jws"
	"github.com/lestrrat-go/jwx/v2/jwt"
)

func getenv(k, def string) string {
	v := os.Getenv(k)
	if v != "" {
		return v
	}
	return def
}

func main() {
	issuer := getenv("RISC_TEST_ISSUER", "https://voltpay.local.test")
	aud := getenv("CAP_AUD", "1018663726434-v2t5nm4npt6taf2j51pp9oaiit89k958.apps.googleusercontent.com")
	url := getenv("RISC_RECEIVER_URL", "http://127.0.0.1:8080/risc/receiver")
	pemPath := getenv("DEV_RSA_PEM", "./.dev/risc_rsa.pem")

	// Load SAME key as JWKS server
	priv, _, err := devkeys.LoadOrCreate(pemPath)
	if err != nil {
		log.Fatal(err)
	}

	// Build token
	t := jwt.New()
	_ = t.Set(jwt.IssuerKey, issuer)
	_ = t.Set(jwt.IssuedAtKey, time.Now())
	_ = t.Set(jwt.ExpirationKey, time.Now().Add(5*time.Minute))
	_ = t.Set(jwt.AudienceKey, []string{aud})
	_ = t.Set(jwt.SubjectKey, "test-google-sub-123")
	_ = t.Set("events", map[string]any{
		"https://schemas.openid.net/secevent/risc/event-type/sessions-revoked": map[string]any{
			"subject": map[string]any{
				"identifier": map[string]any{"value": "test-google-sub-123"},
			},
			"event_timestamp": time.Now().Unix(),
		},
	})

	// Force protected header kid = "test1"
	h := jws.NewHeaders()
	_ = h.Set(jws.KeyIDKey, "test1")

	signed, err := jwt.Sign(t, jwt.WithKey(jwa.RS256, priv, jws.WithProtectedHeaders(h)))
	if err != nil {
		log.Fatal(err)
	}

	resp, err := http.Post(url, "text/plain", bytes.NewReader(signed))
	if err != nil {
		log.Fatal(err)
	}
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {

		}
	}(resp.Body)

	body, _ := io.ReadAll(resp.Body)
	log.Printf("POST %s -> %d %s\n%s", url, resp.StatusCode, resp.Status, string(body))
}
