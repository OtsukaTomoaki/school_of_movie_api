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

ActiveRecord::Schema[7.0].define(version: 2023_04_23_054834) do
  create_table "active_storage_attachments", charset: "utf8mb4", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.string "record_id", limit: 36, null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "messages", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.string "talk_room_id", limit: 36, null: false
    t.string "user_id", limit: 36, null: false
    t.text "content", comment: "メッセージ内容"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["talk_room_id"], name: "index_messages_on_talk_room_id"
  end

  create_table "movie_genre_relations", id: false, charset: "utf8mb4", force: :cascade do |t|
    t.string "movie_id", limit: 36, null: false, comment: "映画ID"
    t.string "movie_genre_id", limit: 36, null: false, comment: "映画ジャンルID"
    t.index ["movie_id", "movie_genre_id"], name: "index_movie_genre_relations_on_movie_id_and_movie_genre_id", unique: true
  end

  create_table "movie_genres", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.string "the_movie_database_id", limit: 36, null: false, comment: "tmdbで管理されているid"
    t.string "name", limit: 100, null: false, comment: "ジャンル名"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["the_movie_database_id"], name: "index_movie_genres_on_the_movie_database_id", unique: true
  end

  create_table "movie_search_words", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.string "word"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "count"
    t.index ["word"], name: "index_movie_search_words_on_word"
  end

  create_table "movies", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.string "the_movie_database_id", limit: 36, null: false, comment: "tmdbで管理されているid"
    t.text "title", null: false, comment: "タイトル"
    t.text "original_title", null: false, comment: "原題"
    t.text "overview", null: false, comment: "概要"
    t.string "poster_path", comment: "ポスター画像パス"
    t.string "backdrop_path", comment: "背景画像パス"
    t.string "original_language", limit: 10, null: false, comment: "言語"
    t.boolean "adult", null: false, comment: "成人向け"
    t.decimal "vote_average", precision: 11, scale: 8, comment: "平均評価"
    t.integer "vote_count", comment: "評価数"
    t.datetime "release_date", comment: "公開日"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["the_movie_database_id"], name: "index_movies_on_the_movie_database_id", unique: true
  end

  create_table "one_time_tokens", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.datetime "expires_at"
    t.json "exchange_json"
  end

  create_table "social_account_mappings", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.integer "social_id", null: false, comment: "SNSのID"
    t.string "email", null: false
    t.string "social_account_id", null: false, comment: "連携するSNSのユーザID"
    t.index ["social_id", "email"], name: "index_social_account_mappings_on_social_id_and_email", unique: true
  end

  create_table "talk_room_permissions", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.string "talk_room_id", limit: 36, null: false
    t.string "user_id", limit: 36, null: false
    t.boolean "owner", default: false, comment: "トークルームのオーナー権限（オーナー、変更、削除権限を変更できる）"
    t.boolean "allow_edit", default: false, comment: "トークルームの変更権限"
    t.boolean "allow_delete", default: false, comment: "トークルームの削除権限"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["talk_room_id", "user_id"], name: "index_talk_room_permissions_on_talk_room_id_and_user_id", unique: true
  end

  create_table "talk_rooms", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.text "name", null: false
    t.text "describe", null: false, comment: "説明"
    t.integer "status", null: false, comment: "トークルームのステータス（非公開, 限定公開, 公開）"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_tags", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.string "user_id", limit: 36, null: false
    t.text "tag", size: :tiny, null: false
    t.datetime "created_at"
  end

  create_table "users", id: { type: :string, limit: 36 }, charset: "utf8mb4", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.string "activation_digest"
    t.boolean "activated", default: false
    t.datetime "activated_at"
    t.string "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
end
