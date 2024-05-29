package webutils

import (
	json "encoding/json"
	http "net/http"
)

func WriteResponse(w http.ResponseWriter, responseBody any, statusCode int) error {
	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(statusCode)

	encodedBody, err := json.Marshal(responseBody)
	if err != nil {
		return err
	}

	_, err = w.Write(encodedBody)
	if err != nil {
		return err
	}
	return nil
}

func DecodeBody(r *http.Request, body any) (error) {
	return json.NewDecoder(r.Body).Decode(&body)
}
