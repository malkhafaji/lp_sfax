require 'open-uri'
include WebServices
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_action  :verify_authenticity_token


  # Taking the fax_number,recipient_name and the attached file path and call the actual sending method to send the fax (made by the client)
  def send_fax
    begin
      Rails.logger.debug "==> request for new fax: #{params.inspect} <=="
      recipient_name = params['recipient_name']
      recipient_number = params['recipient_number']
      callback_url = params['FaxDispositionURL']
      attachments_array = params_to_array(params['Attachments'])
      attachments = []
      original_file_name = ''
      attachments_array.each do |file_info|
        file_info_list = WebServices::Web.file_path(file_info[0])
        attachments << file_info_list[0]
        original_file_name += file_info_list[1]
      end
      fax_record = FaxRecord.new
      fax_record.client_receipt_date = Time.now
      fax_record.recipient_number = recipient_number
      fax_record.recipient_name = recipient_name
      fax_record.file_path = original_file_name
      fax_record.callback_url = callback_url
      fax_record.updated_by_initializer = false
      fax_record.save!
      fax_record_attachment(fax_record, attachments_array)
      initial_response = FaxServices::Fax.actual_sending(recipient_name, recipient_number, attachments, fax_record.id)
      render json: initial_response
    rescue Exception => e
      render json: e.message.inspect
      Rails.logger.debug "==> error send_fax: #{e.message.inspect} <=="
    end
  end

  private
  def params_to_array(string)
    array_of_files_id_and_checksum = []
    j,u = 0,0
    parsed_string= string.split(/[\s,+=]/)
    parsed_string.each do |i|
      j = j+1
        if j % 2 == 0
         array_of_files_id_and_checksum = ( (u % 2 == 0) ? array_of_files_id_and_checksum.push(i.to_i) : array_of_files_id_and_checksum.push(i.to_s) )
          u=u+1
        end
    end
    array_of_files_id_and_checksum.each_slice(2).to_a
  end

  def fax_record_attachment(fax_record, attachments_array)
    attachments_array.each do |file_info|
      Attachment.create(fax_record_id: fax_record.id, file_unique_key: file_info[0])
    end
  end
end
