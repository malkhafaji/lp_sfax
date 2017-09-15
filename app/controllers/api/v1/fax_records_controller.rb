require 'open-uri'
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_action  :verify_authenticity_token, :authenticate_user!

  def send_fax
    begin
      # check_params
      unless params['recipient_name'] && params['recipient_number'] && params['FaxDispositionURL'] && params['Attachments'] && params['e_sk'] && params['let_sk'] && params['type_cd_sk'] && params['priority_cd_sk']
        raise ActionController::ParameterMissing.new('required params')
      end
      callback_server = CallbackServer.find_by_url(params['FaxDispositionURL'])
      unless callback_server
        raise 'callback server does not exist'
      end
      HelperMethods::Logger.app_logger('info', "==> request for new fax: #{params.inspect} <==")
      attachments_array = params_to_array(params['Attachments'])
      fax_record = FaxRecord.new(callback_server_id: callback_server.id, client_receipt_date: Time.now, recipient_number: params['recipient_number'], recipient_name: params['recipient_name'], updated_by_initializer: false)
      respond_to do |format|
        if fax_record.save
          CallbackParam.create(let_sk: params['let_sk'], e_sk: params['e_sk'], type_cd_sk: params['type_cd_sk'], priority_cd_sk: params['priority_cd_sk'], fax_record_id: fax_record.id)
          fax_record_attachment(fax_record, attachments_array)
          FaxJob.perform_async(fax_record.id)
          format.json { render json: { status: 'R', message: 'Fax request has been received' } }
        else
          format.json { render json: fax_record.errors, status: :unprocessable_entity }
        end
      end
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
end
