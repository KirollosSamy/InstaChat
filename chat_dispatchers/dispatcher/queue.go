package dispatcher

// Even though we are only dealing with a single message queue, I chose to bind
// the code to an interface rather than a concrete type. This allows the flexibility
// to swap out the message queue implementation in the future without much changes
// or even support multiple message queues at the same time.

// An interface that any concrete queue must implement.
type Queue interface {
	Enqueue(job Job) error
	CreateJob(req Request, enpoint EndpointConfig) Job
	Close()
}
