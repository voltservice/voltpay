package middleware

import (
	_ "context"
	"net/http"
	"strings"
	"time"

	"github.com/redis/go-redis/v9"
)

type RateLimiter struct {
	rdb    *redis.Client
	limit  int           // allowed requests per window
	window time.Duration // sliding window
	burst  int           // short burst allowance
	prefix string
}

func NewRateLimiter(rdb *redis.Client, limit int, window time.Duration, burst int) *RateLimiter {
	return &RateLimiter{rdb: rdb, limit: limit, window: window, burst: burst, prefix: "rl:quotes:"}
}

func (rl *RateLimiter) keyFor(r *http.Request) string {
	// prefer Firebase UID you verify in your auth middleware (e.g., r.Context())
	uid := r.Header.Get("X-Volt-UID") // or from ctx after Firebase token verification
	if uid != "" {
		return rl.prefix + "uid:" + uid
	}
	ip := r.Header.Get("X-Forwarded-For")
	if ip == "" {
		ip = strings.Split(r.RemoteAddr, ":")[0]
	} else {
		ip = strings.TrimSpace(strings.Split(ip, ",")[0])
	}
	return rl.prefix + "ip:" + ip
}

func (rl *RateLimiter) Middleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// only guard the expensive endpoint
		if r.URL.Path != "/api/quotes" {
			next.ServeHTTP(w, r)
			return
		}
		ctx := r.Context()
		k := rl.keyFor(r)

		// Use a sliding window counter with small burst.
		// INCR key and set TTL if new.
		pipe := rl.rdb.TxPipeline()
		cnt := pipe.Incr(ctx, k)
		pipe.Expire(ctx, k, rl.window)
		_, _ = pipe.Exec(ctx)

		n := int(cnt.Val())
		// soft burst allowance
		if n > rl.limit+rl.burst {
			w.Header().Set("Retry-After", "30")
			http.Error(w, `{"error":"rate_limited"}`, http.StatusTooManyRequests)
			return
		}

		next.ServeHTTP(w, r)
	})
}
