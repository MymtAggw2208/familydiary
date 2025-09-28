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

ActiveRecord::Schema[8.0].define(version: 2025_09_15_052907) do
  create_table "ai_replies", force: :cascade do |t|
    t.integer "diary_id", null: false
    t.text "content"
    t.datetime "replied_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diary_id"], name: "index_ai_replies_on_diary_id"
  end

  create_table "chat_messages", force: :cascade do |t|
    t.integer "daily_chat_id", null: false
    t.text "content"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["daily_chat_id"], name: "index_chat_messages_on_daily_chat_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.integer "diary_id", null: false
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["diary_id"], name: "index_comments_on_diary_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "daily_chats", force: :cascade do |t|
    t.integer "user_id", null: false
    t.date "chat_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_daily_chats_on_user_id"
  end

  create_table "diaries", force: :cascade do |t|
    t.string "title"
    t.text "description"
    t.string "picture"
    t.date "published_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_diaries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "login_id", null: false
    t.string "role"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["login_id"], name: "index_users_on_login_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "ai_replies", "diaries"
  add_foreign_key "chat_messages", "daily_chats"
  add_foreign_key "comments", "diaries"
  add_foreign_key "comments", "users"
  add_foreign_key "daily_chats", "users"
  add_foreign_key "diaries", "users"
end
