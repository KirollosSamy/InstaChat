class ApplicationSerializer < ActiveModel::Serializer
  attributes :app_token, :name, :chats_count, :created_at, :updated_at
end
