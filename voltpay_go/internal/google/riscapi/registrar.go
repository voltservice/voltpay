// Package riscapi internal/google/riscapi/registrar.go
package riscapi

import (
	"bytes"
	"context"
	"encoding/json"
	"net/http"
)

type GoogleRegistrar struct{ HTTP *http.Client }

func (g *GoogleRegistrar) RegisterReceiver(ctx context.Context, uri string, include []string) error {
	body, _ := json.Marshal(map[string]any{
		"receiverUri":           uri,
		"includeSecurityEvents": include,
	})
	req, _ := http.NewRequestWithContext(ctx, "POST",
		"https://risc.googleapis.com/v1beta/registerReceiver", bytes.NewReader(body))
	req.Header.Set("Authorization", "Bearer "+ /* inject ADC access token */ "")
	req.Header.Set("Content-Type", "application/json")
	_, err := g.HTTP.Do(req)
	if err != nil {
		return err
	}

	return nil
}
