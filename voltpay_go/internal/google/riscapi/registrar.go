// Package riscapi provides a tiny client for Google's RISC (Cross-Account Protection) API.
package riscapi

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

type Registrar struct {
	HTTP *http.Client
}

type streamUpdate struct {
	Delivery struct {
		DeliveryMethod string `json:"delivery_method"`
		URL            string `json:"url"`
	} `json:"delivery"`
	EventsRequested []string `json:"events_requested"`
}

// NewRegistrar returns a client that uses ADC (WIF in CI, runtime SA in Cloud Run, or local ADC).
// Required scopes:
//   - stream:update → https://www.googleapis.com/auth/risc.configuration.readwrite
//   - stream:verify → https://www.googleapis.com/auth/risc.verify
func NewRegistrar(ctx context.Context) (*Registrar, error) {
	ts, err := google.DefaultTokenSource(ctx,
		"https://www.googleapis.com/auth/risc.configuration.readwrite",
		"https://www.googleapis.com/auth/risc.verify",
	)
	if err != nil {
		return nil, err
	}
	// Use oauth2.NewClient to wrap the token source with Transport.
	httpClient := oauth2.NewClient(ctx, ts)
	return &Registrar{HTTP: httpClient}, nil
}

func (r *Registrar) UpdateStream(ctx context.Context, receiverURL string, events []string) error {
	var payload streamUpdate
	payload.Delivery.DeliveryMethod = "https://schemas.openid.net/secevent/risc/delivery-method/push"
	payload.Delivery.URL = receiverURL
	payload.EventsRequested = events

	b, _ := json.Marshal(payload)
	req, _ := http.NewRequestWithContext(ctx, "POST",
		"https://risc.googleapis.com/v1beta/stream:update", bytes.NewReader(b))
	req.Header.Set("Content-Type", "application/json")

	resp, err := r.HTTP.Do(req)
	if err != nil {
		return err
	}
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {

		}
	}(resp.Body)

	if resp.StatusCode != http.StatusOK {
		slurp, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("stream:update status=%d body=%s", resp.StatusCode, string(slurp))
	}
	return nil
}

func (r *Registrar) Verify(ctx context.Context, state string) error {
	body, _ := json.Marshal(map[string]string{"state": state})
	req, _ := http.NewRequestWithContext(ctx, "POST",
		"https://risc.googleapis.com/v1beta/stream:verify", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	resp, err := r.HTTP.Do(req)
	if err != nil {
		return err
	}
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {

		}
	}(resp.Body)

	if resp.StatusCode != http.StatusOK {
		slurp, _ := io.ReadAll(resp.Body)
		return fmt.Errorf("stream:verify status=%d body=%s", resp.StatusCode, string(slurp))
	}
	return nil
}
