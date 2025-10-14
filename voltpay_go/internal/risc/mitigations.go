package risc

import (
	"context"
	"log"
	"time"
)

// Mitigator implements your risk responses. This default logs actions and
// returns success (so Google sees 204s). Swap the internals with your real logic:
//   - flag user as high risk in your DB
//   - revoke/kill sessions in Redis
//   - force re-auth / password reset
type Mitigator interface {
	MarkHighRisk(ctx context.Context, userID string) error
	KillSessions(ctx context.Context, userID string) error
}

// --- Default implementation ---

type NoopMitigator struct {
	// Optionally wire dependencies (DB, Redis, Pub/Sub, etc.)
	Logger *log.Logger
}

func (m *NoopMitigator) MarkHighRisk(ctx context.Context, userID string) error {
	l := m.Logger
	if l == nil {
		l = log.Default()
	}
	l.Printf("[RISC] MarkHighRisk user=%s at=%s", userID, time.Now().UTC().Format(time.RFC3339))
	// TODO: e.g., UPDATE users SET risk='high', risk_at=NOW() WHERE id=?
	return nil
}

func (m *NoopMitigator) KillSessions(ctx context.Context, userID string) error {
	l := m.Logger
	if l == nil {
		l = log.Default()
	}
	l.Printf("[RISC] KillSessions user=%s at=%s", userID, time.Now().UTC().Format(time.RFC3339))
	// TODO: e.g., DEL redis keys session:*:userID or call your session service
	return nil
}
