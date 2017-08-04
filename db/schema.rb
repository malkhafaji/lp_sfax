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

ActiveRecord::Schema.define(version: 20170804183140) do

  create_table "attachments", force: :cascade do |t|
    t.integer  "fax_record_id"
    t.integer  "file_id"
    t.string   "checksum"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "file_key"
    t.index ["file_key"], name: "index_attachments_on_file_key"
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
    t.index ["send_fax_queue_id"], name: "index_fax_records_on_send_fax_queue_id", unique: true
  end

end
