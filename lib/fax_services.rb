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
        fax_record = FaxRecord.includes(:attachments).find(fax_id)
        attachments_keys= fax_record.attachments.pluck(:file_key)
        attachments, file_dir=  WebServices::Web.file_path(attachments_keys, fax_id)
        if (attachments.empty?) || (attachments.size != attachments_keys.size)
          fax_record.update_attributes(message: 'Fax request is complete', result_message: "No files found to download for fax with ID: #{fax_id}", error_code: 1515102, result_code: 7002, status: false, is_success: false)
          HelperMethods::Logger.app_logger('error', "==> No files found to download for fax with ID: #{fax_id}")
          InsertFaxJob.perform_async(fax_record.id)
          FileUtils.rm_rf Dir.glob(file_dir)
          return
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
          HelperMethods::Logger.app_logger('error', "==> error send_fax_queue_id is nil: #{response_result} <==")
          fax_record.update_attributes(message: 'Fax request is complete', result_message: 'Transmission not completed', error_code: 1515101, result_code: 7001, status: false, is_success: false)
          InsertFaxJob.perform_async(fax_record.id)
        end
        FaxServices::Fax.sendback_initial_response_to_client(fax_record)
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
              ResendFaxJob.perform_in((ENV['DELAY_RESEND'].to_i).minutes, fax_record.id) unless fax_record.in_queue?
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

      def final_response_to_client
        records_groups = FaxRecord.not_send_to_client
        records_groups.each do |server_id, records|
          callback_server = CallbackServer.find(server_id)
          HelperMethods::Logger.app_logger('info', "==> total #{records.size} records for #{callback_server.name} <==")
          array_of_records =  prepare_client_date(records)
          if array_of_records.blank?
            HelperMethods::Logger.app_logger('info', '==> sendback_final_response_to_client: No responses for faxes found <==')
          else
            array_in_batches = array_of_records.each_slice(ENV['max_records_send_to_client'].to_i).to_a
            array_in_batches.each do |batch_of_records|
              begin
                HelperMethods::Logger.app_logger('info', "==> #{Time.now} posting #{batch_of_records.size} records to #{callback_server.name} <==")
                url = URI(callback_server.update_url+'/eFaxService/OutboundDispositionService.svc/Receive')
                response = HTTParty.post(url, body: batch_of_records.to_json, headers: { 'Content-Type' => 'application/json' } )
                HelperMethods::Logger.app_logger('info', "==> #{Time.now} end posting <==")
                if response.present? && response.code == 200
                  result = JSON.parse(response)
                  success_ids = []
                  result.each do |r|
                    if r['Message'] == 'Success'
                      success_ids << r['Fax_Id']
                      FaxRecord.find(r['Fax_Id']).update_attributes(sendback_final_response_to_client: 1)
                    end
                  end
                  HelperMethods::Logger.app_logger('info', "==> successfully updated: #{success_ids} <==")
                else
                  HelperMethods::Logger.app_logger('error', "==> response error: #{response} <==")
                end
              rescue Exception => e
                HelperMethods::Logger.app_logger('error', "==> Error while posting final response: #{e.message}")
              end
            end
          end
        end
      end

      def old_sendback_final_response_to_client #remove me soon please
        records_groups = FaxRecord.where(sendback_final_response_to_client: 0).where.not(send_fax_queue_id: nil, result_code: nil, callback_url: nil).group_by(&:callback_url)
        records_groups.each do |url, records|
          HelperMethods::Logger.app_logger('info', "==> total #{records.size} records for #{url} <==")
          array_of_records =  prepare_client_date(records)
          if array_of_records.blank?
            HelperMethods::Logger.app_logger('info', '==> sendback_final_response_to_client: No responses for faxes found <==')
          else
            array_in_batches = array_of_records.each_slice(ENV['max_records_send_to_client'].to_i).to_a
            array_in_batches.each do |batch_of_records|
              begin
                HelperMethods::Logger.app_logger('info', "==> #{Time.now} posing #{batch_of_records.size} records to #{url} <==")
                response = HTTParty.post(url,
                  body: batch_of_records.to_json,
                headers: { 'Content-Type' => 'application/json' } )
                HelperMethods::Logger.app_logger('info', "==> #{Time.now} end posting <==")
                if response.present? && response.code == 200
                  result = JSON.parse(response)
                  success_ids = []
                  result.each do |r|
                    if r['Message'] == 'Success'
                      success_ids << r['Fax_Id']
                      FaxRecord.find(r['Fax_Id']).update_attributes(sendback_final_response_to_client: 1)
                    end
                  end
                  HelperMethods::Logger.app_logger('info', "==> successfully updated: #{success_ids} <==")
                else
                  HelperMethods::Logger.app_logger('info', "==> response error: #{response} <==")
                end
              rescue Exception => e
                HelperMethods::Logger.app_logger('error', "==> Error while posting final response: #{e.message}")
              end
            end
          end
        end
      end

      def prepare_client_date(records)
        array_of_records = []
        records.each do |record|
          new_record= {
            Fax_ID: record.id,
            Recipient_Name: record.recipient_name,
            Recipient_Number: record.recipient_number,
            Attached_Fax_File: record.file_path,
            is_success: record.is_success,
            initial_Message: record.message,
            Final_Message: record.result_message,
            Sender_Number: record.sender_fax,
            Number_of_pages: record.pages,
            Number_of_attempts: record.attempts,
            Error_code: record.error_code,
            Client_receipt_date: record.client_receipt_date,
            Send_confirm_date: record.fax_date_utc,
            Vendor_confirm_date: record.send_confirm_date,
            ResultCode: record.result_code,
            fax_duration: record.fax_duration
          }
          array_of_records.push(new_record) unless record.in_queue?
        end
        array_of_records
      end
    end
  end
end
