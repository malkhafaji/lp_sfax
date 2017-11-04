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

ActiveRecord::Schema.define(version: 20170927190713) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "attachments", force: :cascade do |t|
    t.integer  "fax_record_id"
    t.integer  "file_id"
    t.string   "checksum"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "file_key"
  end

  create_table "callback_params", force: :cascade do |t|
    t.integer  "fax_record_id"
    t.integer  "let_sk"
    t.integer  "e_sk"
    t.integer  "type_cd_sk"
    t.integer  "priority_cd_sk"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["fax_record_id"], name: "index_callback_params_on_fax_record_id", using: :btree
  end

  create_table "callback_servers", force: :cascade do |t|
    t.string   "name"
    t.string   "url",         null: false
    t.string   "update_url"
    t.integer  "insert_port"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.index ["insert_port"], name: "index_callback_servers_on_insert_port", using: :btree
    t.index ["update_url"], name: "index_callback_servers_on_update_url", using: :btree
    t.index ["url"], name: "index_callback_servers_on_url", using: :btree
  end

  create_table "fax_records", force: :cascade do |t|
    t.string   "recipient_name"
    t.string   "recipient_number"
    t.string   "file_path"
    t.string   "status"
    t.string   "deprecated_send_fax_queue_id"
    t.string   "message"
    t.string   "send_fax_queue_id"
    t.string   "is_success"
    t.string   "result_message"
    t.string   "recipient_fax"
    t.string   "tracking_code"
    t.string   "fax_id"
    t.string   "watermark_id"
    t.string   "sender_fax"
    t.string   "barcode_items"
    t.string   "out_bound_fax_id"
    t.integer  "pages"
    t.integer  "result_code"
    t.integer  "error_code"
    t.integer  "attempts"
    t.integer  "fax_success"
    t.integer  "max_fax_response_check_tries"
    t.integer  "fax_pages"
    t.boolean  "updated_by_initializer"
    t.integer  "sendback_final_response_to_client", default: 0
    t.datetime "fax_date_utc"
    t.datetime "vendor_confirm_date"
    t.datetime "client_receipt_date"
    t.datetime "send_confirm_date"
    t.datetime "fax_date_iso"
    t.decimal  "fax_duration"
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.string   "callback_url"
    t.integer  "resend",                            default: 0
    t.integer  "callback_server_id"
    t.index ["send_fax_queue_id"], name: "index_fax_records_on_send_fax_queue_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "name"
    t.string   "refresh_token"
    t.string   "access_token"
    t.datetime "access_token_expires_at"
    t.datetime "last_sign_in_at"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
  end

  create_table "vendor_statuses", force: :cascade do |t|
    t.string   "service",    null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["service"], name: "index_vendor_statuses_on_service", using: :btree
  end

  add_foreign_key "callback_params", "fax_records"
end
