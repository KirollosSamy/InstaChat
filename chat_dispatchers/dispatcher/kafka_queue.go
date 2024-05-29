package dispatcher

import (
	kafka "chat-dispatchers/kafka"
	"log"

	"errors"
	uuid "github.com/satori/go.uuid"
)

type KafkaQueue struct {
	producer *kafka.Producer
}

func NewKafkaQueue(config KafkaConfig) *KafkaQueue {
	broker := config.Broker
	producer, err := kafka.NewProducer([]string{broker})
	if err != nil {
		log.Fatalln("Failed to create Kafka producer", err)
		return nil
	}

	return &KafkaQueue{producer: producer}
}

func (kq *KafkaQueue) Enqueue(job Job) error {
	kafkaJob, ok := job.(*KafkaJob)

	if !ok {
		return errors.New("invalid job type")
	}

	err := kq.producer.SendMessage(kafkaJob.Topic, kafkaJob.PartitionKey, job.encode())
	return err
}

func (kq *KafkaQueue) CreateJob(req Request, endpoint EndpointConfig) Job {
	return &KafkaJob{
		ID:           uuid.NewV4().String(),
		Request:      req,
		Topic:        endpoint.Topic,
		PartitionKey: req.Vars[endpoint.PartitionKey],
	}
}

func (kq *KafkaQueue) Close() {
	kq.producer.Close()
}
