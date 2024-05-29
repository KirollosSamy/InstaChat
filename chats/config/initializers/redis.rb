require 'redis'

redis_config = Rails.application.config_for(:redis)

REDIS = Redis.new(host: redis_config[:host], port: redis_config[:port], db: redis_config[:db])

REDIS_APP_TOKENS_KEY = "#{redis_config[:namespace]}:app_tokens"

# Setup initial timestamp used to update chat counts
LAST_UPDATED_TIMESTAMP_KEY = "#{redis_config[:namespace]}:last_updated_timestamp"
