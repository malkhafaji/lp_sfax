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
      def service_alive?
        conn = Faraday.new(url: FAX_SERVER_URL, ssl: { ca_file: 'C:/Ruby200/cacert.pem' }  ) do |faraday|
          faraday.request :multipart
          faraday.request  :url_encoded
          faraday.adapter Faraday.default_adapter
        end
        begin
          if  conn.post.present?
            return true
          end
        rescue
          return false
        end
      end

      # Getting TOKEN
      def get_token
        timestr = Time.now.utc.iso8601()
        raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
        dox = Doxipher.new(ENCRYPTIONKEY, {base64: true})
        cipher = dox.encrypt(raw)
        return cipher
      end

      # sending the fax with the fax_record id
      def send_now(fax_id)
        begin
          fax_record = FaxRecord.includes(:attachments).find(fax_id)
          attachments_keys= fax_record.attachments.pluck(:file_key)
          attachments, file_dir=  WebServices::Web.file_path(attachments_keys)
          if (attachments.empty?) || (attachments.size != attachments_keys.size)
            raise RuntimeError,"No files found to download for fax with ID: #{fax_record.id}"
          end
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
            "RecipientFax=#{fax_record.recipient_number}",
            "RecipientName=#{fax_record.recipient_name}",
          "OptionalParams=&" ]
          path = "/api/" + parts.join("&")
          begin
            response = conn.post path do |req|
              req.body = {}
              attachments.each_with_index do |file, i|
                req.body["file_name#{i}"] = Faraday::UploadIO.new("#{file}", file_specification(file)[0], file_specification(file)[1])
              end
            end
            response_result = JSON.parse(response.body)
            fax_record.update_attributes(
              status:            response_result["isSuccess"],
              message:           response_result["message"],
              send_fax_queue_id: response_result["SendFaxQueueId"],
              max_fax_response_check_tries: 0,
            send_confirm_date: response['date'])
            if fax_record.send_fax_queue_id.nil?
              HelperMethods::Logger.app_logger('info', "==> error send_fax_queue_id is nil: #{response_result} <==")
              fax_record.update_attributes(message: 'Fax request is complete', result_message: 'Transmission not completed', error_code: 1515101, result_code: 7001, status: false, is_success: false)
            end
            FaxServices::Fax.sendback_initial_response_to_client(fax_record)
          rescue Exception => e
            HelperMethods::Logger.app_logger('error', "==> #{e.message} <==")
            HelperMethods::Logger.app_logger('info', "==> Reschedule fax with ID #{fax_record.id} to be send later <==")
            FaxJob.perform_in(1.minutes, fax_id)
          end
        rescue RuntimeError => e
          fax_record.update_attributes(message: 'Fax request is complete', result_message: 'One or more attachment is missing', error_code: 1515102, result_code: 7002, status: false, is_success: false)
          InsertFaxJob.perform_async(fax_record.id)
        rescue Exception => e
          fax_record.update_attributes(message: 'Fax request is complete', result_message: 'Transmission not completed', error_code: 1515101, result_code: 7001, status: false, is_success: false)
          HelperMethods::Logger.app_logger('error', "==> #{e.message} ")
        end
        FileUtils.rm_rf Dir.glob(file_dir)
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
        FaxRecord.without_queue_id.each do |fax|
          begin
            fax.update_attributes( updated_by_initializer: true )
            FaxServices::Fax.send_now(fax.id)
          rescue
            HelperMethods::Logger.app_logger('error', "==> Error sending_faxes_without_queue_id: #{fax.id} <==")
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
        InsertFaxJob.perform_async(fax_record.id)
        if fax_record.updated_by_initializer == true
          HelperMethods::Logger.app_logger('info', "==> sendback_initial_response_to_client/updated_by_initializer: #{client_initial_response} <==")
        else
          HelperMethods::Logger.app_logger('info',  "==> sendback_initial_response_to_client: #{client_initial_response} <==")
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
            fax_record = FaxRecord.find_by_send_fax_queue_id(fax_requests_queue_id)
            parse_response = response["RecipientFaxStatusItems"][0]
            unless fax_record.resend <= ENV['MAX_RESEND'].to_i && parse_response['ResultCode'] == 6000
              HelperMethods::Logger.app_logger('error', "==> final response: #{parse_response} <==")
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
            else
              HelperMethods::Logger.app_logger('info', "==> Resend fax with ID = #{fax_record.id} <==")
              fax_record.update_attributes(resend: (fax_record.resend+1))
              ResendFaxJob.perform_in((ENV['DELAY_RESEND'].to_i).minutes, fax_record.id) unless fax_record.in_schedule_queue?
            end
          else
            HelperMethods::Logger.app_logger('info', '==>fax_response: no response found <==')
          end
        rescue Exception => e
          HelperMethods::Logger.app_logger('error', "==>fax_response error: #{e.message} <==")
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
          VendorStatus.create!(service:'up') if VendorStatus.service_down?
          return JSON.parse(response.body)
        rescue Exception => e
          VendorStatus.create!(service:'down') if VendorStatus.service_up?
          HelperMethods::Logger.app_logger('error', e.message)
        end
      end
    end
  end
end
