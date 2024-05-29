package dispatcher

import (
	"encoding/json"
)

type KafkaJob struct {
	ID   string `json:"id"`
	Request Request `json:"request"`
	Topic string `json:"topic"`
	PartitionKey string `json:"partition_key"`
}

func (job *KafkaJob) encode() []byte {
	data, err := json.Marshal(job)
	if err != nil {
		return []byte{}
	}
	return data
}
