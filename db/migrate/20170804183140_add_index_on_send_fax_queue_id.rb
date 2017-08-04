class AddIndexOnSendFaxQueueId < ActiveRecord::Migration[5.0]
  def change
    add_index :fax_records, :send_fax_queue_id, unique: true
  end
end
