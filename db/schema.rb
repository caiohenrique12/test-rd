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

ActiveRecord::Schema[8.1].define(version: 2026_10_14_221006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "access_tokens", force: :cascade do |t|
    t.string "account_id", null: false
    t.string "token_digest", limit: 64, null: false
    t.index ["account_id"], name: "index_access_tokens_on_account_id"
    t.index ["token_digest"], name: "index_access_tokens_on_token_digest", unique: true
  end

  create_table "accounts", id: :string, force: :cascade do |t|
    t.boolean "credentialed", default: false, null: false
  end

  create_table "payment_links", force: :cascade do |t|
    t.string "account_id", null: false
    t.string "public_id", null: false
    t.string "url_token", null: false
    t.string "status", default: "active", null: false
    t.string "description", limit: 140, null: false
    t.integer "amount_cents", null: false
    t.string "currency", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_payment_links_on_account_id"
    t.index ["public_id"], name: "index_payment_links_on_public_id", unique: true
    t.index ["url_token"], name: "index_payment_links_on_url_token", unique: true
  end

  add_foreign_key "access_tokens", "accounts"
  add_foreign_key "payment_links", "accounts"
end
