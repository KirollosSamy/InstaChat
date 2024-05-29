package dispatcher

import (
	webutils "chat-dispatchers/webutils"
	"fmt"
	"net/http"
	"strconv"
	"time"

	"github.com/gorilla/mux"
)

func CreateChatHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	appToken := vars["app_token"]

	var chatRequest ChatRequest
	err := webutils.DecodeBody(r, &chatRequest)
	if err != nil {
		http.Error(w, "Could not decode request", http.StatusBadRequest)
	}

	valid := ValidateChatRequest(chatRequest, vars, w)
	if !valid {
		return
	}

	key := fmt.Sprintf("%s:%s", GetConfig().AppTokensKey, appToken)
	chatNum, err := GetRedisClient().GenerateID(key)
	if err != nil {
		http.Error(w, "Could not create chat", http.StatusInternalServerError)
		return
	}

	// Initialize the chat with 0 messages
	_, err = GetRedisClient().HSet(appToken, strconv.Itoa(int(chatNum)), strconv.Itoa(0))
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	chatRequest.Chat.ChatNum = int(chatNum)

	req := Request{
		Body: chatRequest,
		URL:  r.URL.String(),
		Vars: vars,
	}

	config := GetConfig().Endpoints["create_chat"]
	err = EnqueueJob(req, config)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
	}

	webutils.WriteResponse(w, chatRequest, http.StatusCreated)
}

func CreateMessageHandler(w http.ResponseWriter, r *http.Request) {
	vars := mux.Vars(r)
	appToken := vars["app_token"]
	chatNum := vars["chat_num"]

	var msgRequest MessageRequest
	err := webutils.DecodeBody(r, &msgRequest)
	if err != nil {
		http.Error(w, "Could not decode request", http.StatusBadRequest)
	}

	valid := ValidateMessageRequest(msgRequest, vars, w)
	if !valid {
		return
	}

	key := fmt.Sprintf("%s:%s:messages", appToken, chatNum)
	MsgNum, err := GetRedisClient().GenerateID(key)
	if err != nil {
		http.Error(w, "Could not create message", http.StatusInternalServerError)
		return
	}

	msgRequest.Message.MessageNum = int(MsgNum)
	msgRequest.Message.MessagedAt = int64(time.Now().UnixNano()) / 1e9

	req := Request{
		Body: msgRequest,
		URL:  r.URL.String(),
		Vars: vars,
	}

	config := GetConfig().Endpoints["create_message"]
	err = EnqueueJob(req, config)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return
	}

	webutils.WriteResponse(w, msgRequest, http.StatusCreated)
}

func EnqueueJob(req Request, endpoint EndpointConfig) error {
	queueName := endpoint.Queue
	queue := GetQueueFactory().GetQueue(queueName)

	job := queue.CreateJob(req, endpoint)
	return queue.Enqueue(job)
}

