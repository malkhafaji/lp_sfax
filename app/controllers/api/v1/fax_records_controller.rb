require 'open-uri'
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_action  :verify_authenticity_token, :authenticate_user!

  def show
    fax_record = FaxRecord.find(params[:id])

    if fax_record
      render json: {id: fax_record.id, client_id: fax_record.client_id, recipient_number: fax_record.recipient_number , recipient_name: fax_record.recipient_name, attachments: fax_record.attachments.count }, status: :ok
    else
      render json: { error: 'We could not find any Fax Record with that id' }, status: :unprocessable_entity
    end
  end

  def send_fax
    begin
      unless params.values_at(*%i(RecipientName RecipientNumber FaxDispositionURL Attachments CreateBy CreateById LetterId TransmissionTypeCodeId PriorityCodeId ClientId)).all?(&:present?)
        raise 'Missing required parameter(s)'
      end
      callback_server = CallbackServer.find_by_url(params['FaxDispositionURL'])
      unless callback_server
        raise 'callback server does not exist'
      end
      attachments_array = params['Attachments'].split(',').map(&:strip)
      fax_record = FaxRecord.new(callback_server_id: callback_server.id, client_receipt_date: Time.now,
        recipient_number: params['RecipientNumber'], recipient_name: params['RecipientName'], client_id: params['ClientId'],
        updated_by_initializer: false, created_by: params['CreateBy'])
      respond_to do |format|
        if fax_record.save
          CallbackParam.create(let_sk: params['LetterId'], e_sk: params['CreateById'], type_cd_sk: params['TransmissionTypeCodeId'], priority_cd_sk: params['PriorityCodeId'], fax_record_id: fax_record.id)
          fax_record_attachment(fax_record, attachments_array)
          FaxJob.perform_async(fax_record.id)
          audit_trails_attributes = {action: 'send_fax', actor: fax_record.created_by, actor_type: 1, event: "new fax request: #{params.inspect}", event_type:'info'}
          LoggerJob.perform_async(audit_trails_attributes, { status: 'R', message: 'Fax request has been received' }, fax_record.to_json)
          format.json { render json: { status: 'R', message: 'Fax request has been received' }, status: :ok }
        else
          audit_trails_attributes = {action: 'send_fax', actor: fax_record.created_by, actor_type: 1, event: "new fax request: #{params.inspect}", event_type:'error'}
          LoggerJob.perform_async(audit_trails_attributes, {error: fax_record.errors.full_messages, status: 'F'}, fax_record.to_json)
          format.json { render json: {error: fax_record.errors.full_messages, status: 'F'} , status: :unprocessable_entity}
        end
      end
    rescue Exception => e
      audit_trails_attributes = {action: 'send_fax', actor: Etc.getlogin, actor_type: 0, event: "new fax request: #{params.inspect}", event_type:'error'}
      LoggerJob.perform_async(audit_trails_attributes, {error: e.message})
      render json: {error: e.message}, status: :unprocessable_entity
    end
  end

  private
  def fax_record_attachment(fax_record, attachments_array)
    attachments_array.each do |file_key|
      Attachment.create(fax_record_id: fax_record.id, file_key: file_key)
    end
  end
end
