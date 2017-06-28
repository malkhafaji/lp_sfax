require 'open-uri'
include WebServices
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_action  :verify_authenticity_token

  def send_fax
    Rails.logger.debug "==> request for new fax: #{params.inspect} <=="
    fax_record = FaxRecord.new(recipient_name: params['recipient_name'],
      recipient_number: params['recipient_number'],
      client_receipt_date: Time.now,
      callback_url: params['FaxDispositionURL'],
    updated_by_initializer: false)
    attachment_from_params = params_to_array(params['Attachments'])
    if fax_record.save!
      $fax_service_status = FaxServices::Fax.checking_server if $fax_service_status.nil?
      if $fax_service_status == true
        NormalWorker.perform_async(fax_record.recipient_name, fax_record.recipient_number, attachment_from_params, fax_record.id)
        $fax_service_status = nil
      else
        fax_record.update_attributes(result_message: 'Queued')
        WaitingWorker.perform_async(fax_record.recipient_name, fax_record.recipient_number, attachment_from_params, fax_record.id)
        $fax_service_status = nil
      end
      fax_record_attachment(fax_record, attachment_from_params)
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
end
