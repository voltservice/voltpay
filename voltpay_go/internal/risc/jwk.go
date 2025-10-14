package risc

import (
	"crypto/rsa"
	"encoding/base64"
	"fmt"
	"math/big"
)

// jwkToRSAPub converts base64url-encoded modulus N and exponent E into an *rsa.PublicKey.
// E is usually small (e.g., AQAB -> 65537) but we parse generically.
func jwkToRSAPub(nB64, eB64 string) (*rsa.PublicKey, error) {
	nb, err := base64.RawURLEncoding.DecodeString(nB64)
	if err != nil {
		return nil, fmt.Errorf("decode N: %w", err)
	}
	eb, err := base64.RawURLEncoding.DecodeString(eB64)
	if err != nil {
		return nil, fmt.Errorf("decode E: %w", err)
	}

	var n big.Int
	n.SetBytes(nb)

	// Convert big-endian bytes to int
	e := 0
	for _, b := range eb {
		e = (e << 8) | int(b)
	}
	if e <= 0 {
		return nil, fmt.Errorf("invalid exponent")
	}

	return &rsa.PublicKey{N: &n, E: e}, nil
}
