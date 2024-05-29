package main

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"

	disp "chat-dispatchers/dispatcher"
)

func main() {
	r := mux.NewRouter()

	r.HandleFunc("/applications/{app_token}/chats", disp.CreateChatHandler).Methods(http.MethodPost)
	r.HandleFunc("/applications/{app_token}/chats/{chat_num}/messages", disp.CreateMessageHandler).Methods(http.MethodPost)

	host := fmt.Sprintf(":%d", disp.GetConfig().Port)
	log.Default().Printf("Listening on %s", host)

	err := http.ListenAndServe(host, r)
	if err != nil {
		log.Fatalf("Server failed to start: %v", err)
	}
}

