package devkeys

import (
	"crypto/rand"
	"crypto/rsa"
	"crypto/x509"
	"encoding/pem"
	"errors"
	"os"

	"github.com/lestrrat-go/jwx/v2/jwk"
)

const defaultKID = "test1"

// LoadOrCreate loads an RSA private key from PEM at path,
// or generates a new 2048-bit key and saves it.
// Returns the private JWK and a JWKS with the corresponding public key.
func LoadOrCreate(pemPath string) (jwk.Key, jwk.Set, error) {
	priv, err := loadRSAPrivateKey(pemPath)
	if err != nil {
		if !errors.Is(err, os.ErrNotExist) {
			return nil, nil, err
		}
		// generate & save
		priv, err = rsa.GenerateKey(rand.Reader, 2048)
		if err != nil {
			return nil, nil, err
		}
		if err := saveRSAPrivateKey(pemPath, priv); err != nil {
			return nil, nil, err
		}
	}

	// private JWK for signing
	privJWK, err := jwk.FromRaw(priv)
	if err != nil {
		return nil, nil, err
	}
	_ = privJWK.Set(jwk.KeyIDKey, defaultKID)
	_ = privJWK.Set(jwk.AlgorithmKey, "RS256")
	_ = privJWK.Set(jwk.KeyUsageKey, "sig")

	// public JWKS for verification
	pubJWK, err := jwk.PublicKeyOf(privJWK)
	if err != nil {
		return nil, nil, err
	}
	set := jwk.NewSet()
	if err := set.AddKey(pubJWK); err != nil {
		return nil, nil, err
	}
	return privJWK, set, nil
}

func loadRSAPrivateKey(path string) (*rsa.PrivateKey, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	block, _ := pem.Decode(b)
	if block == nil || block.Type != "RSA PRIVATE KEY" {
		return nil, errors.New("invalid PEM")
	}
	key, err := x509.ParsePKCS1PrivateKey(block.Bytes)
	if err != nil {
		return nil, err
	}
	return key, nil
}

func saveRSAPrivateKey(path string, key *rsa.PrivateKey) error {
	if err := os.MkdirAll(dir(path), 0o755); err != nil && !errors.Is(err, os.ErrExist) {
		return err
	}
	f, err := os.OpenFile(path, os.O_CREATE|os.O_WRONLY|os.O_TRUNC, 0o600)
	if err != nil {
		return err
	}
	defer func(f *os.File) {
		err := f.Close()
		if err != nil {

		}
	}(f)

	block := &pem.Block{
		Type:  "RSA PRIVATE KEY",
		Bytes: x509.MarshalPKCS1PrivateKey(key),
	}
	return pem.Encode(f, block)
}

func dir(path string) string {
	for i := len(path) - 1; i >= 0; i-- {
		if path[i] == '/' || path[i] == '\\' {
			return path[:i]
		}
	}
	return "."
}

//package devkeys
//
//import (
//	"crypto/rand"
//	"crypto/rsa"
//
//	"github.com/lestrrat-go/jwx/v2/jwk"
//)
//
//var (
//	privJWK jwk.Key
//	jwksSet jwk.Set
//)
//
//func init() {
//	// Generate a single RSA keypair for the whole module (dev only).
//	rsaPriv, err := rsa.GenerateKey(rand.Reader, 2048)
//	if err != nil {
//		panic(err)
//	}
//	// Private JWK (not exposed publicly; signer uses this)
//	k, err := jwk.FromRaw(rsaPriv)
//	if err != nil {
//		panic(err)
//	}
//	_ = k.Set(jwk.KeyIDKey, "test1")
//	_ = k.Set(jwk.AlgorithmKey, "RS256")
//	_ = k.Set(jwk.KeyUsageKey, "sig")
//	privJWK = k
//
//	// Public JWKS (what the receiver fetches)
//	pub, err := jwk.PublicKeyOf(k)
//	if err != nil {
//		panic(err)
//	}
//	set := jwk.NewSet()
//	if err := set.AddKey(pub); err != nil {
//		panic(err)
//	}
//	jwksSet = set
//}
//
//// PrivateKeyJWK returns the private JWK for signing (dev only).
//func PrivateKeyJWK() jwk.Key { return privJWK }
//
//// JWKS returns the public JWK set for publishing.
//func JWKS() jwk.Set { return jwksSet }
