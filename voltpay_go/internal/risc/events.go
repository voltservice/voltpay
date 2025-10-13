// Package risc internal/risc/events.go
package risc

import "context"

type Event struct {
	UserID    string
	Type      string
	Timestamp int64
}

type Mitigator interface {
	MarkHighRisk(ctx context.Context, userID string) error
	KillSessions(ctx context.Context, userID string) error
}

type Registrar interface {
	RegisterReceiver(ctx context.Context, receiverURI string, include []string) error
}
