ActiveRecord::Schema.define(version: 20170215222848) do

  create_table "fax_requests", force: :cascade do |t|
    t.string   "recipient_name",      null: false
    t.string   "recipient_number",    null: false
    t.string   "file_path",           null: false
    t.date     "client_receipt_date"
    t.string   "status"
    t.string   "message"
    t.date     "send_confirm_date"
    t.date     "vendor_confirm_date"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

end
