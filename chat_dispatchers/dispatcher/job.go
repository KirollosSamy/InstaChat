package dispatcher

// Job is an interface that any concrete job must implement.
// A Job concrete type is associated with a specific message queue implementation.
type Job interface {
	encode() []byte
}