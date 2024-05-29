class Message < ApplicationRecord
  include Searchable
  
  # belongs_to :chat

  DISALLOWED_COLUMNS = %w[id chat_id].freeze
  VALID_SORT_BY = %w[message_num messaged_at].freeze 

  def self.paginate(app_token, chat_num, page_token, limit)
    messages = Message.select(Message.column_names - DISALLOWED_COLUMNS)
                      .where('(app_token, chat_num, message_num, messaged_at) >= (?, ?, ?, ?)', app_token, chat_num, page_token[:message_num], page_token[:messaged_at])
                      .order(messaged_at: :asc, message_num: :asc)
                      .limit(limit + 1)

    if messages.size > limit
      next_page_token = { messaged_at: messages.last.messaged_at, message_num: messages.last.message_num }
    end

    messages = messages.first(limit)
    [messages, next_page_token]
  end

  def self.build_query(params)
    puts params
    query = {
      from: (params[:page] - 1) * params[:limit],
      size: params[:limit],
      sort: {
        params[:sort_by] => { order: "asc" }
      },
      query: {
        bool: {
          must: [
            { match: { content: params[:q] } },
            { term: { chat_num: params[:chat_num] } },
            { term: { "app_token.keyword": params[:app_token] } }
            # { term: { app_token: params[:app_token] } }
          ]
        }
      }
    }

    query
  end
end