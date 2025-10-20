package handlers

import (
	"context"
	"encoding/json"
	_ "errors"
	"fmt"
	_ "io"
	"net/http"
	"strconv"
	"strings"
	"time"
)

type QuoteResponse struct {
	SourceCurrency  string  `json:"sourceCurrency"`
	TargetCurrency  string  `json:"targetCurrency"`
	SourceAmount    float64 `json:"sourceAmount"`
	Rate            float64 `json:"rate"`
	RecipientAmount float64 `json:"recipientAmount"`
	Fees            []Fee   `json:"fees"`
	GuaranteeSec    int     `json:"guaranteeSeconds"`
	ArrivalSec      int     `json:"arrivalSeconds"`
}

type Fee struct {
	Label  string  `json:"label"`
	Amount float64 `json:"amount"`
	Code   string  `json:"code"`
}

type exchangerateAPIResp struct {
	Result         string  `json:"result"`
	ConversionRate float64 `json:"conversion_rate"`
}

type QuoteDeps struct {
	HTTP   *http.Client
	APIKey string
	Cache  *RateCache
}

func (d QuoteDeps) Handle(w http.ResponseWriter, r *http.Request) {
	q := r.URL.Query()
	source := strings.ToUpper(strings.TrimSpace(q.Get("source")))
	if source == "" {
		source = "USD"
	}
	target := strings.ToUpper(strings.TrimSpace(q.Get("target")))
	if target == "" {
		target = "EUR"
	}

	amount, _ := strconv.ParseFloat(q.Get("amount"), 64)
	if amount <= 0 {
		amount = 1000
	}

	method := strings.TrimSpace(q.Get("method"))
	if method == "" {
		method = "wire"
	}

	if strings.TrimSpace(d.APIKey) == "" {
		http.Error(w, `{"error":"missing_api_key"}`, http.StatusInternalServerError)
		return
	}

	// NEW: (rate, src, err)
	rate, src, err := d.fetchRate(r.Context(), source, target)
	if err != nil {
		fmt.Printf("[quotes] fetchRate error: %v\n", err)

		msg := err.Error()
		code := http.StatusBadGateway
		if strings.Contains(msg, "provider status 401") ||
			strings.Contains(msg, "provider status 403") ||
			strings.Contains(msg, "provider status 404") {
			code = http.StatusBadRequest
		}
		http.Error(w, fmt.Sprintf(`{"error":"provider","detail":%q}`, msg), code)
		return
	}
	if rate <= 0 {
		http.Error(w, `{"error":"invalid_rate"}`, http.StatusBadGateway)
		return
	}

	methodFee := feeForMethod(method)
	ourFee := 3.76
	totalFees := methodFee + ourFee
	recipient := (amount - totalFees) * rate

	resp := QuoteResponse{
		SourceCurrency:  source,
		TargetCurrency:  target,
		SourceAmount:    amount,
		Rate:            rate,
		RecipientAmount: round2(recipient),
		Fees: []Fee{
			{Label: "Payment method fee", Amount: methodFee, Code: "payment_method_fee"},
			{Label: "Our fee", Amount: ourFee, Code: "our_fee"},
		},
		GuaranteeSec: 11 * 60 * 60,
		ArrivalSec:   arrivalForMethod(method),
	}

	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "private, max-age=30")
	if src != "" {
		w.Header().Set("X-Rate-Source", src) // "cache" or "upstream"
	}
	_ = json.NewEncoder(w).Encode(resp)
}

func (d QuoteDeps) fetchRate(ctx context.Context, source, target string) (float64, string, error) {
	if d.Cache != nil {
		if r, ok := d.Cache.Get(ctx, source, target); ok {
			return r, "cache", nil
		}
	}
	// client with 4s timeout is good if Cloud Run is 15s
	if d.HTTP == nil {
		d.HTTP = &http.Client{Timeout: 4 * time.Second}
	}
	// (optional) light retry on timeout/5xx
	rate, err := d.callUpstreamWithRetry(ctx, source, target)
	if err != nil {
		// fallback: try cache again (maybe a concurrent request populated it)
		if d.Cache != nil {
			if r, ok := d.Cache.Get(ctx, source, target); ok {
				return r, "cache", nil
			}
		}
		return 0, "", err
	}
	if d.Cache != nil {
		d.Cache.Set(ctx, source, target, rate)
	}
	return rate, "upstream", nil
}

func feeForMethod(m string) float64 {
	switch m {
	case "wire":
		return 6.11
	case "debitCard":
		return 12.35
	case "creditCard":
		return 61.65
	case "accountTransfer":
		return 0.0
	default:
		return 6.11
	}
}

func arrivalForMethod(m string) int {
	switch m {
	case "wire":
		return 4 * 60 * 60
	default:
		return 2 * 60 * 60
	}
}

func round2(v float64) float64 {
	return float64(int(v*100+0.5)) / 100
}
