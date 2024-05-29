class UpdateCountsJob < ApplicationJob
  queue_as :default

  UPDATE_CHATS_COUNT_QUERY = <<-SQL
  WITH latest_chats AS (
    SELECT app_token, COUNT(*) AS count
    FROM chats
    WHERE created_at > ? AND created_at <= ?
    GROUP BY app_token
  )
  UPDATE applications AS app
  JOIN latest_chats ON app.app_token = latest_chats.app_token
  SET app.chats_count = app.chats_count + latest_chats.count
SQL

  UPDATE_MSGS_COUNT_QUERY = <<-SQL
  WITH latest_msgs AS (
    SELECT app_token, chat_num, COUNT(*) AS count
    FROM messages
    WHERE created_at > ? AND created_at <= ?
    GROUP BY app_token, chat_num
  )
  UPDATE chats AS C
  JOIN latest_msgs ON C.app_token = latest_msgs.app_token AND C.chat_num = latest_msgs.chat_num
  SET C.messages_count = C.messages_count + latest_msgs.count
SQL

  def perform(*args)
    current_timestamp = Time.now
    last_updated_timestamp = REDIS.getset(LAST_UPDATED_TIMESTAMP_KEY, current_timestamp)
    last_updated_timestamp = last_updated_timestamp ? Time.parse(last_updated_timestamp) : Time.at(0)

    chats_query = ActiveRecord::Base.send(:sanitize_sql_array, [UPDATE_CHATS_COUNT_QUERY, last_updated_timestamp, current_timestamp])
    ActiveRecord::Base.connection.execute(chats_query)

    messages_query = ActiveRecord::Base.send(:sanitize_sql_array, [UPDATE_MSGS_COUNT_QUERY, last_updated_timestamp, current_timestamp])
    ActiveRecord::Base.connection.execute(messages_query)
  end
end
