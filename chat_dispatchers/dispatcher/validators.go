package dispatcher

import (
	"net/http"
	"strconv"

	"github.com/go-playground/validator/v10"
)

func ValidateChatRequest(req ChatRequest, vars map[string]string, w http.ResponseWriter) bool {
	appToken := vars["app_token"]

	validate := validator.New()

    err := validate.Struct(req)
    if err != nil {
        http.Error(w, "Invalid create chat request", http.StatusBadRequest)
        return false
    }

	exists, err := GetRedisClient().HExists(GetConfig().AppTokensKey, appToken)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return false
	}
	if !exists {
		http.Error(w, "Application does not exist", http.StatusNotFound)
		return false
	}

	return true
}

func ValidateMessageRequest(req MessageRequest, vars map[string] string, w http.ResponseWriter) bool {
	appToken := vars["app_token"]
	chatNum := vars["chat_num"]

	validate := validator.New()

    err := validate.Struct(req)
    if err != nil {
        http.Error(w, "Invalid create chat request", http.StatusBadRequest)
        return false
    }

	num, err := strconv.Atoi(chatNum)
	if err != nil || num <= 0 {
		http.Error(w, "chat number must be a positive integer", http.StatusBadRequest)
		return false
	}

	exists, err := GetRedisClient().HExists(appToken, chatNum)
	if err != nil {
		http.Error(w, "Internal server error", http.StatusInternalServerError)
		return false
	}
	if !exists {
		http.Error(w, "Chat does not exist", http.StatusNotFound)
		return false
	}

	return true
}
