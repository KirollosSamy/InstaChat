# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_05_20_190356) do
  create_table "applications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "app_token", null: false
    t.string "name", null: false
    t.integer "chats_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_token"], name: "index_applications_on_app_token", unique: true
  end

  create_table "chats", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "chat_num", null: false
    t.string "name", null: false
    t.integer "messages_count", default: 0, null: false
    t.string "app_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_token", "chat_num"], name: "index_chats_on_app_token_and_chat_num"
    t.index ["app_token", "created_at"], name: "index_chats_on_app_token_and_created_at"
  end

  create_table "messages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "message_num", null: false
    t.datetime "messaged_at", null: false
    t.string "content"
    t.string "messaged_by", null: false
    t.string "app_token", null: false
    t.integer "chat_num", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["app_token", "chat_num", "created_at"], name: "index_messages_on_app_token_and_chat_num_and_created_at"
    t.index ["app_token", "chat_num", "message_num"], name: "index_messages_on_app_token_and_chat_num_and_message_num"
  end

  add_foreign_key "chats", "applications", column: "app_token", primary_key: "app_token"
end
