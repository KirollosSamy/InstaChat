package kafka

import (
	"log"

	"github.com/IBM/sarama"
)

// A simple wrapper around kafka client (currently, sarama)
// so our code is not tightly coupled with any kafka client library.
type Producer struct {
    client sarama.SyncProducer
}

func NewProducer(brokers []string) (*Producer, error) {
    config := sarama.NewConfig()
    config.Producer.Return.Successes = true
    client, err := sarama.NewSyncProducer(brokers, config)
    
    if err != nil {
        return nil, err
    }
    return &Producer{client: client}, nil
}

func (p *Producer) SendMessage(topic string, key string, value []byte) error {
    msg := &sarama.ProducerMessage{
        Topic: topic,
        Key:   sarama.StringEncoder(key),
        Value: sarama.ByteEncoder(value),
    }

    _, _, err := p.client.SendMessage(msg)
    if err != nil {
        log.Printf("Could not send message: %v", err)
        return err
    }
    return nil
}

func (p *Producer) Close() error {
    if err := p.client.Close(); err != nil {
        log.Printf("Could not close client: %v", err)
        return err
    }
    return nil
}