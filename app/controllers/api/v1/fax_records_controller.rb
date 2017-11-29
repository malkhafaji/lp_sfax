require 'open-uri'
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_action  :verify_authenticity_token, :authenticate_user!

  def show
    fax_records = FaxRecord.find_by(id: params[:id])

    if fax_records
      render json: fax_records, root: false
    else
      render json: { error: "We could not find any Fax Record with that id" }, status: 404
    end
  end

  def send_fax
    begin
      unless params['recipient_name'].present? && params['recipient_number'].present? && params['FaxDispositionURL'].present? && params['Attachments'].present? && params['e_sk'].present? && params['let_sk'].present? && params['type_cd_sk'].present? && params['priority_cd_sk'].present?
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
          HelperMethods::Logger.app_logger('error', fax_record.errors)
          format.json { render json: fax_record.errors, status: 'F' }
        end
      end
    rescue Exception => e
      HelperMethods::Logger.app_logger('error', "send_fax: #{e.message}")
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
