class UpdateFaxRecordsWithoutAttachments < ActiveRecord::Migration[5.0]

  def up
    FaxRecord.without_queue_id.each do |fax|
      unless fax.attachments.any?
        fax.update_attributes( result_message: "Transmission not completed", result_code: '7001', status: false )
      end
    end
  end

  def down
    FaxRecord.without_queue_id.each do |fax|
      unless fax.attachments.any?
        fax.update_attributes( result_message: nil, result_code: nil, status: nil )
      end
    end
  end
end
