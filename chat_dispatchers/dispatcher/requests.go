package dispatcher

// Request encapsulated the required information form http.request type
type Request struct {
	Body any `json:"body"`
	URL string `json:"url"`
	Vars map[string]string `json:"vars"`
}

// The definitions of DTOs used to define the body of the requests

type ChatRequest struct {
	Chat struct {
		ChatNum int `json:"chat_num"`
		Name    string `json:"name" validate:"required"`
	} `json:"chat"`
}

type MessageRequest struct {
	Message struct {
		MessageNum int `json:"message_num"`
		MessagedAt int64 `json:"messaged_at"`
		Content    string `json:"content" validate:"required"`
		MessagedBy string `json:"messaged_by" validate:"required"`
	} `json:"message"`
}
