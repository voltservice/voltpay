package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"voltpay_go/internal/devkeys"
)

func main() {
	pemPath := os.Getenv("DEV_RSA_PEM")
	if pemPath == "" {
		pemPath = "./.dev/risc_rsa.pem"
	}
	_, jwks, err := devkeys.LoadOrCreate(pemPath)
	if err != nil {
		log.Fatal(err)
	}

	http.HandleFunc("/test/jwks.json", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		_ = json.NewEncoder(w).Encode(jwks)
	})

	log.Println("JWKS dev server on :8081 /test/jwks.json (kid=test1) using", pemPath)
	log.Fatal(http.ListenAndServe(":8081", nil))
}
