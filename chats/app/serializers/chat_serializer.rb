class ChatSerializer < ActiveModel::Serializer
  attributes :chat_num, :name, :messages_count, :created_at, :updated_at
end
