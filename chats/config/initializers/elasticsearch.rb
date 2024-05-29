es_config = Rails.application.config_for(:elasticsearch)

ES_HOST = es_config[:host]
ES_NUMBER_OF_SHARDS = es_config[:number_of_shards]

Elasticsearch::Model.client = Elasticsearch::Client.new(url: ES_HOST)
