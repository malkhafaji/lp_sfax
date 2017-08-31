require 'open-uri'
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_action  :verify_authenticity_token, :authenticate_user!
  before_action :check_params

  # Taking the fax_number,recipient_name and the attached file path and call the actual sending method to send the fax (made by the client)
  def send_fax
    begin
      unless Rails.application.config.can_send_fax
        WebServices::Web.client_fax_service_status
        Rails.application.config.can_send_fax = FaxServices::Fax.service_alive?
      end
      callback_params = {e_sk: params['e_sk'], let_sk: params['let_sk'], type_cd_sk: params['type_cd_sk'], priority_cd_sk: params['priority_cd_sk']}
      callback_server = CallbackServer.find_by_url(params['FaxDispositionURL'])
      Rails.logger.debug "==> request for new fax: #{params.inspect} <=="
      recipient_name = params['recipient_name']
      recipient_number = params['recipient_number']
      attachments_array = params_to_array(params['Attachments'])
      attachments=  WebServices::Web.file_path(attachments_array)
      fax_record = FaxRecord.new
      fax_record.callback_server_id = callback_server.id
      fax_record.client_receipt_date = Time.now
      fax_record.recipient_number = recipient_number
      fax_record.recipient_name = recipient_name
      fax_record.updated_by_initializer = false
      fax_record.save!
      fax_record_attachment(fax_record, attachments_array)
      FaxJob.perform_async(recipient_name, recipient_number, attachments, fax_record.id, callback_params)
      render json: {status: 'success'}
    rescue Exception => e
      HelperMethods::Logger.app_logger('error', e.message)
      render json: e.message
    end
  end

  private
  def params_to_array(string)
    array_of_files_key = []
    parsed_string= string.split(/[\s,+=]/)
    (1..parsed_string.length - 1).step(4).each do |i|
      array_of_files_key << parsed_string[i]
    end
    array_of_files_key
  end

  def fax_record_attachment(fax_record, attachments_array)
    attachments_array.each do |file_key|
      Attachment.create(fax_record_id: fax_record.id, file_key: file_key)
    end
  end

  # Check the presents of the required Parameters
  def check_params
    params_list = ['recipient_name', 'recipient_number', 'FaxDispositionURL', 'Attachments', 'e_sk', 'let_sk', 'type_cd_sk', 'priority_cd_sk']
    params_list.each do |i|
      params[i].presence || raise(ActionController::ParameterMissing.new(i))
    end
  end

end
