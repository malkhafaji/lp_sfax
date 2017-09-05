require 'open-uri'
class Api::V1::FaxRecordsController < ApplicationController
  skip_before_action  :verify_authenticity_token, :authenticate_user!
  # before_action :check_params

  # Taking the fax_number,recipient_name and the attached file path and call the actual sending method to send the fax (made by the client)
  def send_fax
    begin
      check_params
      unless Rails.application.config.can_send_fax
        Rails.application.config.can_send_fax = FaxServices::Fax.service_alive?
      end
      callback_params = {e_sk: params['e_sk'], let_sk: params['let_sk'], type_cd_sk: params['type_cd_sk'], priority_cd_sk: params['priority_cd_sk']}
      callback_server = CallbackServer.find_by_url(params['FaxDispositionURL'])
      unless callback_server
        raise 'callback server does not exist'
      end
      HelperMethods::Logger.app_logger('info', "==> request for new fax: #{params.inspect} <==")
      attachments_array = params_to_array(params['Attachments'])
      fax_record = FaxRecord.new(callback_server_id: callback_server.id, client_receipt_date: Time.now, recipient_number: params['recipient_number'], recipient_name: params['recipient_name'], updated_by_initializer: false)
      respond_to do |format|
        if fax_record.save
          fax_record_attachment(fax_record, attachments_array)
          if Rails.application.config.can_send_fax
            pending_queue = Sidekiq::Queue.new("pending_fax")
            pending_queue.each do |job|
              FaxJob.perform_async(job.args[0], job.args[1], job.args[2], job.args[3])
              job.delete if job.jid == "#{job.jid}"
              sleep 5
            end
            FaxJob.perform_async(fax_record.recipient_name, fax_record.recipient_number, fax_record.id, callback_params)
          else
            PendingFaxJob.perform_async(fax_record.recipient_name, fax_record.recipient_number, fax_record.id, callback_params)
          end
          format.json { head :ok }
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

  # Check the presents of the required Parameters
  def check_params
    params_list = ['recipient_name', 'recipient_number', 'FaxDispositionURL', 'Attachments', 'e_sk', 'let_sk', 'type_cd_sk', 'priority_cd_sk']
    params_list.each do |i|
      params[i].presence || raise(ActionController::ParameterMissing.new(i))
    end
  end

end
