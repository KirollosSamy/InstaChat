class MessageSerializer < ActiveModel::Serializer
  attributes :message_num, :content, :messaged_at, :created_at, :updated_at, :messaged_by
end
