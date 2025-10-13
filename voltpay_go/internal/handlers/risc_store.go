package handlers

import (
	"sync"
	"time"
)

type RISCEvent struct {
	UserID     string    `json:"user_id"`
	EventType  string    `json:"event_type"`
	ReceivedAt time.Time `json:"received_at"`
}

type RISCStore struct {
	mu   sync.Mutex
	data []RISCEvent
	ttl  time.Duration
}

func NewRISCStore(ttl time.Duration) *RISCStore {
	st := &RISCStore{ttl: ttl}
	go st.reaper()
	return st
}

func (s *RISCStore) Add(e RISCEvent) {
	s.mu.Lock()
	s.data = append(s.data, e)
	s.mu.Unlock()
}

func (s *RISCStore) List() []RISCEvent {
	s.mu.Lock()
	defer s.mu.Unlock()
	out := make([]RISCEvent, len(s.data))
	copy(out, s.data)
	return out
}

func (s *RISCStore) reaper() {
	ticker := time.NewTicker(time.Minute)
	defer ticker.Stop()
	for range ticker.C {
		cutoff := time.Now().Add(-s.ttl)
		s.mu.Lock()
		dst := s.data[:0]
		for _, e := range s.data {
			if e.ReceivedAt.After(cutoff) {
				dst = append(dst, e)
			}
		}
		s.data = dst
		s.mu.Unlock()
	}
}
