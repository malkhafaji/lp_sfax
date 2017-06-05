require 'open-uri'
include WebServices
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_action  :verify_authenticity_token

  def send_fax
    Rails.logger.debug "==> request for new fax: #{params.inspect} <=="
    original_file_name, attachments_array = get_attachments(params_to_array(params['Attachments']))
    fax_record = FaxRecord.new(recipient_name: params['recipient_name'],
        recipient_number: params['recipient_number'], client_receipt_date: Time.now,
        callback_url: params['FaxDispositionURL'], updated_by_initializer: false)
    if fax_record.save!
      fax_record_attachment(fax_record, attachments_array)
      render json: {status: 200}
    else
      Rails.logger.debug "==> error send_fax: #{e.message.inspect} <=="
      render json: fax_record.errors
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
        Attachment.create(fax_record_id: fax_record.id, file_id: file_info[0], checksum: file_info[1])
      end
    end

    def create_initial_response(fax_record)
      initial_response = {
        fax_id: fax_record.id,
        recipient_name: fax_record.recipient_name,
        recipient_number: fax_record.recipient_number,
        message: fax_record.message,
        status: fax_record.status,
        result_message: fax_record.result_message}
      return initial_response
    end

    def get_attachments(array)
      original_file_name = ''
      attachments = []
      array.each_with_index do |file_info|
        file_info = WebServices::Web.file_path(file_info[0], file_info[1])
        attachments << file_info[0]
        original_file_name += file_info[1]
      end
      return original_file_name, attachments
    end
end
