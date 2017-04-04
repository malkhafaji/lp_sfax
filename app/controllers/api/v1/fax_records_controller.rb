require 'open-uri'
include WebServices
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_filter  :verify_authenticity_token


  # Taking the fax_number,recipient_name and the attached file path and call the actual sending method to send the fax (made by the client)
  def send_fax
    begin
      recipient_name = params['recipient_name']
      recipient_number = params['recipient_number']
      checksum = params['checksum']
      file_path = file_path(params['file_id'],checksum)
      fax_record =FaxRecord.new
      fax_record.client_receipt_date = Time.now
      fax_record.recipient_number = recipient_number
      fax_record.recipient_name = recipient_name
      fax_record.file_path = file_path
      fax_record.save!
      actual_sending(recipient_name, recipient_number, file_path, fax_record.id, fax_record.update_attributes(updated_by_initializer: false))
    rescue Exception => e
      render json: e.message.inspect
    end
  end

end
