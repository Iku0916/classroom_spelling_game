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

ActiveRecord::Schema[7.1].define(version: 2026_02_08_062931) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "game_rooms", force: :cascade do |t|
    t.string "game_code"
    t.integer "status"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.integer "time_limit"
    t.bigint "word_kit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "host_user_id"
    t.index ["host_user_id"], name: "index_game_rooms_on_host_user_id"
    t.index ["word_kit_id"], name: "index_game_rooms_on_word_kit_id"
  end

  create_table "guests", force: :cascade do |t|
    t.string "session_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "learning_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_learning_logs_on_user_id"
  end

  create_table "participants", force: :cascade do |t|
    t.string "nickname", null: false
    t.integer "score", default: 0
    t.boolean "is_ready", default: false, null: false
    t.bigint "game_room_id", null: false
    t.bigint "guest_id"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_room_id"], name: "index_participants_on_game_room_id"
    t.index ["guest_id"], name: "index_participants_on_guest_id"
    t.index ["user_id"], name: "index_participants_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "crypted_password", null: false
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_score"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "word_cards", force: :cascade do |t|
    t.string "english_word"
    t.string "japanese_translation"
    t.bigint "word_kit_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word_kit_id"], name: "index_word_cards_on_word_kit_id"
  end

  create_table "word_kits", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_word_kits_on_user_id"
  end

  add_foreign_key "game_rooms", "users", column: "host_user_id"
  add_foreign_key "game_rooms", "word_kits"
  add_foreign_key "learning_logs", "users"
  add_foreign_key "participants", "game_rooms"
  add_foreign_key "participants", "guests"
  add_foreign_key "participants", "users"
  add_foreign_key "word_cards", "word_kits"
  add_foreign_key "word_kits", "users"
end
