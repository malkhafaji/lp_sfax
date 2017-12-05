require 'open-uri'
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_action  :verify_authenticity_token, :authenticate_user!
  
  def show
    fax_record = FaxRecord.find(params[:id])

    if fax_record
      render json: {id: fax_record.id, client_id: fax_record.client_id, recipient_number: fax_record.recipient_number , recipient_name: fax_record.recipient_name, attachments: fax_record.attachments.count }, status: :ok
    else
      render json: { error: 'We could not find any Fax Record with that id' }, status: 404
    end
  end

  def send_fax
    begin
      unless params.values_at(*%i(RecipientName RecipientNumber FaxDispositionURL Attachments CreateById LetterId TransmissionTypeCodeId PriorityCodeId ClientId)).all?(&:present?)
        raise ActionController::ParameterMissing.new('required params')
      end
      callback_server = CallbackServer.find_by_url(params['FaxDispositionURL']) 
      unless callback_server
        raise 'callback server does not exist'
      end
      HelperMethods::Logger.app_logger('info', "==> request for new fax: #{params.inspect} <==")
      attachments_array = params_to_array(params['Attachments'])
      fax_record = FaxRecord.new(callback_server_id: callback_server.id, client_receipt_date: Time.now, recipient_number: params['RecipientNumber'], recipient_name: params['RecipientName'], client_id: params['ClientId'], updated_by_initializer: false)
      respond_to do |format|
        if fax_record.save
          CallbackParam.create(let_sk: params['LetterId'], e_sk: params['CreateById'], type_cd_sk: params['TransmissionTypeCodeId'], priority_cd_sk: params['PriorityCodeId'], fax_record_id: fax_record.id)
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
