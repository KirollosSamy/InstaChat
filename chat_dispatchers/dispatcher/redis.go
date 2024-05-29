package dispatcher

import (
	"fmt"
	"strings"
	"sync"

	"github.com/go-redis/redis"
)

// Wrapper around the Redis client to encapsulate redis functionality
type RedisClient struct {
    client *redis.Client
}

var redisInstance *RedisClient
var redisOnce sync.Once

func GetRedisClient() *RedisClient {
    redisOnce.Do(func() {
        addr := fmt.Sprintf("%s:%d", GetConfig().Redis.Host, GetConfig().Redis.Port)
        client := redis.NewClient(&redis.Options{
            Addr: addr,
            DB:   GetConfig().Redis.DB,
        })

        redisInstance = &RedisClient{client: client}
    })
    return redisInstance
}

// Assumes that key has the form "hashKey:field"
func (g *RedisClient) GenerateID(key string) (int64, error) {
    splitKey := strings.Split(key, ":")
    hashKey, field := splitKey[0], splitKey[1]

    // Prepend the namespace to the hash key
    hashKey = fmt.Sprintf("%s:%s", GetConfig().Redis.NameSpace, hashKey)

	return g.client.HIncrBy(hashKey, field, 1).Result()
}

func (g *RedisClient) HExists(key, field string) (bool, error) {
	key = fmt.Sprintf("%s:%s", GetConfig().Redis.NameSpace, key)
	return g.client.HExists(key, field).Result()
}

func (g *RedisClient) HSet(key, field, value string) (bool, error){
	key = fmt.Sprintf("%s:%s", GetConfig().Redis.NameSpace, key)
	return g.client.HSet(key, field, value).Result()
}