class Chat < ApplicationRecord
  # belongs_to :application, foreign_key: :app_token, primary_key: :app_token
  # we can add an association to the Application model to make queries more convenient and provide validations
  # However, this will cost us an additional query to fetch the application record.
  # Instead, we create a foreign key constraint to ensure referential integrity.

  DISALLOWED_COLUMNS = %w[id application_id].freeze

  def self.paginate(app_token, page_token, limit)
    chats = Chat.select(Chat.column_names - DISALLOWED_COLUMNS)
            .where('(app_token, chat_num) >= (?, ?)', app_token, page_token)
            .order(:chat_num)
            .limit(limit + 1)   

    next_page_token = chats.last.chat_num if chats.size > limit
    chats = chats.first(limit)

    [chats, next_page_token]
  end
  
end
