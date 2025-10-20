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
)

func (d QuoteDeps) callUpstreamWithRetry(ctx context.Context, source, target string) (float64, error) {
	maxRetries := 2
	backoff := 250 * time.Millisecond

	for attempt := 0; attempt <= maxRetries; attempt++ {
		rate, err := d.callUpstreamOnce(ctx, source, target)
		if err == nil {
			return rate, nil
		}

		// Retry only for temporary network / 5xx errors
		if isTransient(err) && attempt < maxRetries {
			time.Sleep(backoff)
			backoff *= 2
			continue
		}
		return 0, err
	}
	return 0, errors.New("unreachable")
}

// callUpstreamOnce
func (d QuoteDeps) callUpstreamOnce(ctx context.Context, source, target string) (float64, error) {
	key := strings.TrimSpace(d.APIKey)
	if key == "" {
		return 0, fmt.Errorf("missing rates API key")
	}

	url := fmt.Sprintf("https://v6.exchangerate-api.com/v6/%s/pair/%s/%s", key, source, target)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return 0, fmt.Errorf("build request failed: %w", err)
	}

	resp, err := d.HTTP.Do(req)
	if err != nil {
		return 0, fmt.Errorf("upstream call failed: %w", err)
	}
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {

		}
	}(resp.Body)

	if resp.StatusCode >= 500 && resp.StatusCode < 600 {
		return 0, fmt.Errorf("provider status %d", resp.StatusCode)
	}
	if resp.StatusCode != http.StatusOK {
		b, _ := io.ReadAll(io.LimitReader(resp.Body, 2048))
		return 0, fmt.Errorf("provider status %d: %.200s", resp.StatusCode, string(b))
	}

	var body exchangerateAPIResp
	if err := json.NewDecoder(resp.Body).Decode(&body); err != nil {
		return 0, fmt.Errorf("decode failed: %w", err)
	}
	if body.Result != "success" || body.ConversionRate <= 0 {
		return 0, errors.New("bad_provider_payload")
	}
	return body.ConversionRate, nil
}

// helper to decide if an error is retryable
func isTransient(err error) bool {
	msg := err.Error()
	return strings.Contains(msg, "timeout") ||
		strings.Contains(msg, "connection reset") ||
		strings.Contains(msg, "temporary") ||
		strings.Contains(msg, "provider status 5")
}
