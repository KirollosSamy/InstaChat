class CreateApplications < ActiveRecord::Migration[7.0]
  def change
    create_table :applications do |t|
      t.string :app_token, null: false
      t.string :name, null: false
      t.integer :chats_count, default: 0, null: false

      t.timestamps

      t.index :app_token, unique: true
    end
  end
end
