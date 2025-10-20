package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"sync"
	"time"

	"github.com/redis/go-redis/v9"
)

type rateEntry struct {
	Rate float64   `json:"rate"`
	Exp  time.Time `json:"exp"`
}

type RateCache struct {
	mu   sync.RWMutex
	mem  map[string]rateEntry
	ttl  time.Duration
	rdb  *redis.Client
	rttl time.Duration
}

func NewRateCache(rdb *redis.Client, ttl, rttl time.Duration) *RateCache {
	return &RateCache{mem: make(map[string]rateEntry), ttl: ttl, rdb: rdb, rttl: rttl}
}

func (c *RateCache) key(src, tgt string) string { return fmt.Sprintf("fx:%s:%s", src, tgt) }

func (c *RateCache) Get(ctx context.Context, src, tgt string) (float64, bool) {
	k := c.key(src, tgt)

	// 1) in-memory
	c.mu.RLock()
	e, ok := c.mem[k]
	c.mu.RUnlock()
	if ok && time.Now().Before(e.Exp) {
		return e.Rate, true
	}

	// 2) Redis
	if c.rdb != nil {
		s, err := c.rdb.Get(ctx, k).Result()
		if err == nil && s != "" {
			var re rateEntry
			if json.Unmarshal([]byte(s), &re) == nil && time.Now().Before(re.Exp) {
				// warm memory
				c.mu.Lock()
				c.mem[k] = re
				c.mu.Unlock()
				return re.Rate, true
			}
		}
	}

	return 0, false
}

func (c *RateCache) Set(ctx context.Context, src, tgt string, rate float64) {
	k := c.key(src, tgt)
	re := rateEntry{Rate: rate, Exp: time.Now().Add(c.ttl)}

	// memory
	c.mu.Lock()
	c.mem[k] = re
	c.mu.Unlock()

	// Redis
	if c.rdb != nil {
		b, _ := json.Marshal(re)
		_ = c.rdb.Set(ctx, k, string(b), c.rttl).Err()
	}
}
