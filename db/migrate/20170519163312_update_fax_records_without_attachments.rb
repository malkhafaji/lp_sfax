class UpdateFaxRecordsWithoutAttachments < ActiveRecord::Migration[5.0]

  def up
    FaxRecord.without_queue_id.each do |fax|
      unless fax.attachments.any?
        puts "updating #{fax.id}"
        fax.update_attributes(is_success: false, message: 'Fax request is complete', result_message: 'Transmission not completed', error_code: '1515101', result_code: '7001', status: false, is_success: false)
      end
    end
  end

  def down
    FaxRecord.without_queue_id.each do |fax|
      unless fax.attachments.any?
        puts "updating #{fax.id}"
        fax.update_attributes(is_success: nil, message: nil, result_message: nil, error_code: nil, result_code: nil, status: nil)
      end
    end
  end
end
