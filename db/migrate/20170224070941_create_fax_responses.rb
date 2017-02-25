class CreateFaxResponses < ActiveRecord::Migration[5.0]
  def change
    create_table :fax_responses do |t|
      t.string :send_fax_queue_id
      t.string :is_success
      t.integer :result_code
      t.integer :error_code
      t.string :result_message
      t.string :recipient_name
      t.string :recipient_fax
      t.string :tracking_code
      t.date :fax_date_utc
      t.string :fax_id
      t.integer :pages
      t.integer :attempts
      t.string :sender_fax
      t.string :barcode_items
      t.integer :fax_success
      t.string :out_bound_fax_id
      t.integer :fax_pages
      t.date :fax_date_iso
      t.string :watermark_id
      t.string :is_success
      t.string :message
      t.references :fax_request, foreign_key: true

      t.timestamps
    end
  end
end
