class CreateMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :messages do |t|
      t.integer :message_num, null: false
      t.datetime :messaged_at, null: false
      t.string :content
      t.string :messaged_by, null: false

      # Unfortunately rails doesn't support composite foreign keys
      # Thus, we must ensure referential integrity in the application layer
      # Alternativily, we can create the composite foreign key directly in MySQL
      t.string :app_token, null: false
      t.integer :chat_num, null: false

      t.timestamps

      t.index [:app_token, :chat_num, :message_num]
      t.index [:app_token, :chat_num, :created_at] # Used for updating messages_count in Chat
    end
  end
end
