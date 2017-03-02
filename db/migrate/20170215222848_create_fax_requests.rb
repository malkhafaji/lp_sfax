class CreateFaxRequests < ActiveRecord::Migration[5.0]
  def change
    create_table :fax_requests do |t|
      t.string :recipient_name, null:false
      t.string :recipient_number, null:false
      t.string :file_path, null:false
      t.datetime   :client_receipt_date
      t.string :status
      t.string :SendFaxQueueId
      t.string :message
      t.integer :max_fax_response_check_tries
      t.datetime :send_confirm_date
      t.datetime   :vendor_confirm_date
      t.references :fax_response, foreign_key: true
      t.timestamps
    end
  end
end
