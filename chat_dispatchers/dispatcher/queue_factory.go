package dispatcher

import (
	"log"
	"sync"
)

type QueueFactory struct {
	_queues map[string]Queue
}

var queueFactoryInstance *QueueFactory
var queueFactoryOnce sync.Once

func GetQueueFactory() *QueueFactory {
    queueFactoryOnce.Do(func() {
        queueFactoryInstance = &QueueFactory{}
		queueFactoryInstance._queues = make(map[string]Queue)
		queueFactoryInstance._queues["kafka"] = NewKafkaQueue(GetConfig().Kafka)
    })
    return queueFactoryInstance
}

func (qf *QueueFactory) GetQueue(queueName string) Queue {
	queue, ok := qf._queues[queueName]
	if !ok {
		log.Fatal("Unsoported queue type")
	}
	return queue
}