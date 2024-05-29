class CreateChats < ActiveRecord::Migration[7.0]
  def change
    create_table :chats do |t|
      t.integer :chat_num, null: false
      t.string :name, null: false
      t.integer :messages_count, default: 0, null: false

      t.string :app_token, null: false

      t.timestamps

      t.index [:app_token, :chat_num]
      t.index [:app_token, :created_at]
    end

    add_foreign_key :chats, :applications, column: :app_token, primary_key: :app_token
  end
end
