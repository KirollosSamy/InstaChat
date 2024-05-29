package dispatcher

import (
	"log"
	"strings"
	"sync"

	"github.com/spf13/viper"
)

type EndpointConfig struct {
	Name         string `mapstructure:"name"`
	Queue        string `mapstructure:"queue"`
	Topic        string `mapstructure:"topic"`
	PartitionKey string `mapstructure:"partition_key"`
}

type KafkaConfig struct {
	Broker string `mapstructure:"broker"`
}

type RedisConfig struct {
	Host      string `mapstructure:"host"`
	Port      int    `mapstructure:"port"`
	DB        int    `mapstructure:"db"`
	NameSpace string `mapstructure:"namespace"`
}

type Config struct {
	Endpoints    map[string]EndpointConfig `mapstructure:"endpoints"`
	Kafka        KafkaConfig               `mapstructure:"kafka"`
	Redis        RedisConfig               `mapstructure:"redis"`
	Port         int                       `mapstructure:"port"`
	AppTokensKey string                    `mapstructure:"app_tokens_key"`
}

var configInstance *Config
var configOnce sync.Once

// Returns the singleton instance of the Config struct
func GetConfig() *Config {
	configOnce.Do(func() {
		var err error
		configInstance, err = ReadConfig("config/config.yaml")
		if err != nil {
			log.Fatalf("Failed to read config: %v", err)
		}
	})
	return configInstance
}

func ReadConfig(configFile string) (*Config, error) {
	config := &Config{}
	viper.SetConfigFile(configFile)

	if err := viper.ReadInConfig(); err != nil {
		return nil, err
	}

	// Automatically bind environment variables
	viper.AutomaticEnv()
	viper.SetEnvKeyReplacer(strings.NewReplacer(".", "_"))

	if err := viper.Unmarshal(config); err != nil {
		return nil, err
	}

	return config, nil
}
