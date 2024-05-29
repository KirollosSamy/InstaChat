module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    include Elasticsearch::Model::Callbacks

    settings index: { number_of_shards: ES_NUMBER_OF_SHARDS } do
      mappings dynamic: 'false' do
        indexes :content, type: 'text'
        indexes :app_token, type: 'keyword'
        indexes :chat_num, type: 'integer'
      end
    end

    def self.search(query)
      self.__elasticsearch__.search(query).records.to_a
    end    
  end
end