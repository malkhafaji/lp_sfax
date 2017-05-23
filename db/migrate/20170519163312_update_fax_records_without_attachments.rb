class UpdateFaxRecordsWithoutAttachments < ActiveRecord::Migration[5.0]


    FaxRecord.without_queue_id.each do |fax|
      unless fax.attachments.any?
        fax.update_attributes( result_message: "Transmission not completed", result_code: '7001', status: false )
      end
    end


end
