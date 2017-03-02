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

ActiveRecord::Schema.define(version: 20170224070941) do

  create_table "fax_requests", force: :cascade do |t|
    t.string   "recipient_name",               null: false
    t.string   "recipient_number",             null: false
    t.string   "file_path",                    null: false
    t.datetime "client_receipt_date"
    t.string   "status"
    t.string   "SendFaxQueueId"
    t.string   "message"
    t.integer  "max_fax_response_check_tries"
    t.datetime "send_confirm_date"
    t.datetime "vendor_confirm_date"
    t.integer  "fax_response_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["fax_response_id"], name: "index_fax_requests_on_fax_response_id"
  end

  create_table "fax_responses", force: :cascade do |t|
    t.string   "send_fax_queue_id"
    t.string   "is_success"
    t.integer  "result_code"
    t.integer  "error_code"
    t.string   "result_message"
    t.string   "recipient_name"
    t.string   "recipient_fax"
    t.string   "tracking_code"
    t.date     "fax_date_utc"
    t.string   "fax_id"
    t.integer  "pages"
    t.integer  "attempts"
    t.string   "sender_fax"
    t.string   "barcode_items"
    t.integer  "fax_success"
    t.string   "out_bound_fax_id"
    t.integer  "fax_pages"
    t.date     "fax_date_iso"
    t.string   "watermark_id"
    t.string   "message"
    t.integer  "fax_request_id"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
    t.index ["fax_request_id"], name: "index_fax_responses_on_fax_request_id"
  end

end
