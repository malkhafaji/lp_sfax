require 'doxifer.rb'
require 'faraday'
require 'pp'
require 'time'
require 'json'
require 'fileutils'
include WebServices
# The requirements to connect with Vendor
USERNAME = ENV['username']
APIKEY = ENV['APIkey']
VECTOR = ENV['vector']
ENCRYPTIONKEY = ENV['encryptionkey']
FAX_SERVER_URL = ENV['fax_server_url']
module FaxServices
  class Fax
    class << self
      # Getting TOKEN
      def get_token
        timestr = Time.now.utc.iso8601()
        raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
        dox = Doxipher.new(ENCRYPTIONKEY, {base64: true})
        cipher = dox.encrypt(raw)
        return cipher
      end

      # sending the fax with the parameters fax_number,recipient_name ,attached file_path,fax_id and define either its sent by user call or by initializer call
      def actual_sending(recipient_name, recipient_number, attachments, fax_id)
        begin
          tid = nil
          conn = Faraday.new(url: FAX_SERVER_URL, ssl: { ca_file: 'C:/Ruby200/cacert.pem' }  ) do |faraday|
            faraday.request :multipart
            faraday.request  :url_encoded
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end
          token = get_token()
          parts = ["sendfax?",
            "token=#{CGI.escape(token)}",
            "ApiKey=#{CGI.escape(APIKEY)}",
            "RecipientFax=#{recipient_number}",
            "RecipientName=#{recipient_name}",
          "OptionalParams=&" ]
          path = "/api/" + parts.join("&")
          response = conn.post path do |req|
            req.body = {}
            attachments.each_with_index do |file, i|
              req.body["file_name#{i}"] = Faraday::UploadIO.new("#{file}", file_specification(file)[0], file_specification(file)[1])
            end
          end
          response_result = JSON.parse(response.body)
          fax_record = FaxRecord.find_by(id: fax_id)
          fax_record.update_attributes(
            status:            response_result["isSuccess"],
            message:           response_result["message"],
            send_fax_queue_id:    response_result["SendFaxQueueId"],
            send_confirm_date: response['date'])
          FileUtils.rm_rf Dir.glob("#{Rails.root}/tmp/fax_files/*")
          if fax_record.send_fax_queue_id.nil?
            Rails.logger.debug "==> error send_fax_queue_id is nil: #{response_result} <=="
            fax_record.update_attributes(is_success: false, message: 'Fax request is complete', result_message: 'Transmission not completed', error_code: '1515101', result_code: '7001', status: false, is_success: false)
          end
          FaxServices::Fax.sendback_initial_response_to_client(fax_record)
        rescue
          fax_record.update_attributes(is_success: false, message: 'Fax request is complete', result_message: 'Transmission not completed', error_code: '1515101', result_code: '7001', status: false, is_success: false)
          Rails.logger.debug "==> Error actual_sending: #{fax.id} <=="
        end
      end
      # Getting the File Name , the File Extension and validate the document type
      def file_specification(file_path)
        file_name = File.basename ("#{file_path}").downcase
        file_extension = File.extname (file_name).downcase
        accepted_extensions = [".tif", ".xls", ".doc", ".pdf", ".docx", ".txt", ".rtf", ".xlsx", ".ppt", ".odt", ".ods", ".odp", ".bmp", ".gif", ".jpg", ".png"]
         if accepted_extensions.include?(file_extension)
           return "application/#{file_extension}", file_name
         else
          return false
         end
      end

      # search and find all faxes without Queue_id (not sent yet) and send them by call from the initializer (when the server start)
      def sending_faxes_without_queue_id
        attachments= []
        FaxRecord.where(send_fax_queue_id: nil).each do |fax|
          begin
            Attachment.where(fax_record_id:fax.id).each do |file|
              file_info = WebServices::Web.file_path(file[:file_id],file[:checksum])
              attachments << file_info[0]
            end
            fax.update_attributes( updated_by_initializer: true)
            FaxServices::Fax.actual_sending(fax.recipient_name ,fax.recipient_number, attachments ,fax.id)
          rescue
            Rails.logger.debug "==> Error sending_faxes_without_queue_id: #{fax.id} <=="
          end
        end
      end

      # Sending the initial response to the client after sending the fax
      def sendback_initial_response_to_client(fax_record)
        client_initial_response = {
          fax_id: fax_record.id,
          recipient_name: fax_record.recipient_name,
          recipient_number: fax_record.recipient_number,
          attached_fax_file: fax_record.file_path,
          success:  fax_record.status,
          message: fax_record.message,
          status: fax_record.status,
          result_message: fax_record.result_message,
        client_receipt_date: fax_record.client_receipt_date}
        #we should put here the client URL to send the json

        if fax_record.updated_by_initializer == true
          Rails.logger.debug "==> sendback_initial_response_to_client/updated_by_initializer: #{client_initial_response} <=="
        elsif fax_record.resend > 0 && fax_record.record_completed == false
          Rails.logger.debug "==> sendback_initial_response_to_client/Resend: #{client_initial_response} <=="
        else
          Rails.logger.debug "==> sendback_initial_response_to_client: #{client_initial_response} <=="
          client_initial_response
        end
      end

      def calculate_duration(t1,t2)
        return ((t2 - t1) / 60.0).round(2)
      end

      # Getting the response for certain fax defained by the SendFaxQueueId
      def  fax_response(fax_requests_queue_id)
        begin
          response = send_fax_status(fax_requests_queue_id)
          if response["RecipientFaxStatusItems"].present?
            parse_response = response["RecipientFaxStatusItems"][0]
            Rails.logger.debug "==> final response: #{parse_response} <=="
            fax_record = FaxRecord.find_by_send_fax_queue_id(fax_requests_queue_id)
            if parse_response['ResultCode'] == 0
              fax_duration = calculate_duration(fax_record.client_receipt_date, (Time.parse(parse_response['FaxDateUtc'])))
              result_message = 'Success'
            else
              result_message = parse_response['ResultMessage']
              fax_duration = 0.0
            end
            fax_record.update_attributes(
              send_fax_queue_id:   parse_response['SendFaxQueueId'],
              is_success:          parse_response['IsSuccess'],
              error_code:          parse_response['ErrorCode'],
              recipient_name:      parse_response['RecipientName'],
              recipient_fax:       parse_response['RecipientFax'],
              tracking_code:       parse_response['TrackingCode'],
              fax_date_utc:        parse_response['FaxDateUtc'],
              fax_id:              parse_response['FaxId'],
              pages:               parse_response['Pages'],
              attempts:            parse_response['Attempts'],
              sender_fax:          parse_response['SenderFax'],
              barcode_items:       parse_response['BarcodeItems'],
              fax_success:         parse_response['FaxSuccess'],
              out_bound_fax_id:    parse_response['OutBoundFaxId'],
              fax_pages:           parse_response['FaxPages'],
              fax_date_iso:        parse_response['FaxDateIso'],
              watermark_id:        parse_response['WatermarkId'],
              message:             response['message'],
              result_code:         parse_response['ResultCode'],
              result_message:      result_message,
              fax_duration:        fax_duration
            )
            if parse_response['ResultCode'] != 6000
              fax_record.update_attributes(record_completed: true)
            end
          else
            Rails.logger.debug '==>fax_response: no response found <=='
          end
        rescue Exception => e
          Rails.logger.debug "==>fax_response error: #{e.message} <=="
        end
      end

      # Sending the Fax_Queue_Id to get the status
      def send_fax_status(fax_requests_queue_id)
        begin
          conn = Faraday.new(url: FAX_SERVER_URL, ssl: { ca_file: 'C:/Ruby200/cacert.pem' }) do |faraday|
            faraday.request  :url_encoded
            faraday.response :logger
            faraday.adapter Faraday.default_adapter
          end
          token = FaxServices::Fax.get_token()
          parts = ["sendfaxstatus?",
            "token=#{CGI.escape(token)}",
            "ApiKey=#{CGI.escape(APIKEY)}",
          "SendFaxQueueId=#{(fax_requests_queue_id)}"]
          path = "/api/"+parts.join("&")

          response = conn.get path do |req|
            req.body = {}
          end
          return JSON.parse(response.body)
        rescue Exception => e
          Rails.logger.debug "==>send_fax_status error: #{e.message} <=="
        end
      end
    end
  end
end