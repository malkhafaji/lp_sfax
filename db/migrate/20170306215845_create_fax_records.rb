class CreateFaxRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :fax_records do |t|
      t.string :recipient_name
      t.string :recipient_number
      t.string :file_path
      t.string :status
      t.string :SendFaxQueueId
      t.string :message
      t.string :send_fax_queue_id
      t.string :is_success
      t.string :result_message
      t.string :recipient_fax
      t.string :tracking_code
      t.string :fax_id
      t.string :watermark_id
      t.string :message
      t.string :sender_fax
      t.string :barcode_items
      t.string :out_bound_fax_id
      t.integer :pages
      t.integer :result_code
      t.integer :error_code
      t.integer :attempts
      t.integer :fax_success
      t.integer :max_fax_response_check_tries
      t.integer :fax_pages
      t.integer :sendback_final_response_to_client,  default: 0
      t.boolean :updated_by_initializer
      t.date :fax_date_utc
      t.date :vendor_confirm_date
      t.date :client_receipt_date
      t.date :send_confirm_date
      t.date :fax_date_iso
      t.timestamps
    end
  end
end
