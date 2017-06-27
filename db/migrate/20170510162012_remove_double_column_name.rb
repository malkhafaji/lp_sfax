class RemoveDoubleColumnName < ActiveRecord::Migration[5.0]
  def change
    records = FaxRecord.where(send_fax_queue_id: nil)
    records.each do |r|
      r.update_attributes(send_fax_queue_id: r.SendFaxQueueId)
    end
    rename_column :fax_records, :SendFaxQueueId, :deprecated_send_fax_queue_id
  end
end
