package config

import (
	"log"
	"os"
	"time"
)

type Config struct {
	Port               string
	ExchangeRateAPIKey string
	AllowedOriginsCSV  string
	HTTPClientTimeout  time.Duration
}

func Load() Config {
	port := os.Getenv("PORT")
	if port == "" {
		port = "9099"
	}
	key := os.Getenv("EXCHANGE_RATE_API_KEY") // required in prod
	if key == "" {
		log.Println("[warn] EXCHANGE_RATE_API_KEY is empty (ok for local dev if you stub responses)")
	}
	allowed := os.Getenv("ALLOWED_ORIGINS")
	if allowed == "" {
		allowed = "https://metalbrain.net,https://www.metalbrain.net,http://localhost:5001,http://localhost:3000"
	}
	return Config{
		Port:               port,
		ExchangeRateAPIKey: key,
		AllowedOriginsCSV:  allowed,
		HTTPClientTimeout:  6 * time.Second,
	}
}
