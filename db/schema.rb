# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170715202424) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "web_data", force: :cascade do |t|
    t.string "key"
    t.string "value_s"
    t.integer "value_i"
    t.float "value_f"
    t.bigint "web_data_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["web_data_id"], name: "index_web_data_on_web_data_id"
  end

  create_table "web_datum_related_keys", force: :cascade do |t|
    t.integer "web_datum_id"
    t.integer "related_key_id"
  end

  create_table "web_statuses", force: :cascade do |t|
    t.string "url"
    t.boolean "is_parsed"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "web_data", "web_data", column: "web_data_id"
end
