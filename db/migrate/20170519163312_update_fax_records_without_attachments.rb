class UpdateFaxRecordsWithoutAttachments < ActiveRecord::Migration[5.0]


    FaxRecord.where(file_path: nil).each do |fax|
        fax.result_message = "Fax sending failed - No attachments"
        fax.result_code = 9000
        fax.status = false
        fax.save!
    end



end
