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

      # sending the fax with the fax_record id
      def send_now(fax_id)
        fax_record = FaxRecord.includes(:attachments).find(fax_id)
        attachments_keys= fax_record.attachments.pluck(:file_key)
        attachments, file_dir=  WebServices::Web.file_path(attachments_keys, fax_id)
        if (attachments.empty?) || (attachments.size != attachments_keys.size)
          fax_record.update_attributes(message: 'Fax request is complete', result_message: "No files found to download for fax with ID: #{fax_id}", error_code: 1515102, result_code: 7002, status: false, is_success: false, send_fax_queue_id: "InvalidFaxAttachment#{fax_record.id}", sender_fax: '1', pages: 0, attempts: 0, fax_duration: 0)

          audit_trails_attributes = {action: 'workflow', actor: fax_record.created_by, actor_type: 1, event: "send_now: No files found to download for fax with ID: #{fax_id}", event_type:'error'}
          LoggerJob.perform_async(audit_trails_attributes, {error: "No files found to download for fax with ID: #{fax_id}", status: 'F'}, fax_record.to_json)
          # HelperMethods::Logger.app_logger('error', "send_now: No files found to download for fax with ID: #{fax_id}")

          InsertFaxJob.perform_async(fax_record.id)  unless fax_record.resend > 0
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

          audit_trails_attributes = {action: 'workflow', actor: fax_record.created_by, actor_type: 1, event: "send_now: error send_fax_queue_id is nil: #{response_result}", event_type:'error'}
          LoggerJob.perform_async(audit_trails_attributes, {error: "send_now: error send_fax_queue_id is nil: #{response_result}", status: 'F'}, fax_record.to_json)
          # HelperMethods::Logger.app_logger('error', "send_now: error send_fax_queue_id is nil: #{response_result}")

          fax_record.update_attributes(message: 'Fax request is complete', result_message: 'Transmission not completed', error_code: 1515101, result_code: 7001, status: false, is_success: false, send_fax_queue_id: "InvalidFaxParams#{fax_record.id}", sender_fax: '1', pages: 0, attempts: 0, fax_duration: 0)
        elsif fax_record.send_fax_queue_id == '-1'

          audit_trails_attributes = {action: 'workflow', actor: fax_record.created_by, actor_type: 1, event: "send_now: #{response_result}", event_type:'error'}
          LoggerJob.perform_async(audit_trails_attributes, {error: "send_now: #{response_result}", status: 'F'}, fax_record.to_json)
          # HelperMethods::Logger.app_logger('error', "send_now: #{response_result}")

          fax_record.update_attributes(result_message: 'Invalid fax number', error_code: 1515102, result_code: 7002, status: false, is_success: false, send_fax_queue_id: "InvalidFaxNumber#{fax_record.id}", sender_fax: '1', pages: 0, attempts: 0, fax_duration: 0)
        end
        InsertFaxJob.perform_async(fax_record.id)  unless fax_record.resend > 0
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

            audit_trails_attributes = {action: 'workflow', actor: fax.created_by, actor_type: 1, event: "Error sending_faxes_without_queue_id: #{fax.id}", event_type:'error'}
            LoggerJob.perform_async(audit_trails_attributes, {error: "Error sending_faxes_without_queue_id: #{fax.id}", status: 'F'}, fax.to_json)
            # HelperMethods::Logger.app_logger('error', "sending_faxes_without_queue_id: Error sending_faxes_without_queue_id: #{fax.id}")

          end
        end
      end

      def calculate_duration(t1,t2)
        return ((t2 - t1) / 60.0).round(2)
      end

      # Getting the response for certain fax defained by the SendFaxQueueId
      def fax_response(fax_requests_queue_id)
        begin
          response = send_fax_status(fax_requests_queue_id)
          if response["RecipientFaxStatusItems"].present?
            fax_record = FaxRecord.find_by_send_fax_queue_id(fax_requests_queue_id)
            parse_response = response["RecipientFaxStatusItems"][0]
            unless parse_response['ResultCode'] == 6000 && fax_record.resend <= ENV['MAX_RESEND'].to_i

              audit_trails_attributes = {action: 'update', actor: fax_record.created_by, actor_type: 1, event: "fax_response: #{parse_response}", event_type:'info'}
              LoggerJob.perform_async(audit_trails_attributes, {response: parse_response}, fax_record.to_json)
              # HelperMethods::Logger.app_logger('info', "fax_response: #{parse_response}")

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
              unless fax_record.in_any_queue?

              audit_trails_attributes = {action: 'workflow', actor: fax_record.created_by, actor_type: 1, event: "fax_response: Resend fax with ID = #{fax_record.id}", event_type:'info'}
                LoggerJob.perform_async(audit_trails_attributes, {}, fax_record.to_json)
                # HelperMethods::Logger.app_logger('info', "fax_response: Resend fax with ID = #{fax_record.id}")

                fax_record.update_attributes(resend: (fax_record.resend+1))
                ResendFaxJob.perform_in((ENV['DELAY_RESEND'].to_i).minutes, fax_record.id)
              end
            end
          else

            audit_trails_attributes = {action: 'workflow', actor: fax_record.created_by, actor_type: 1, event: 'fax_response: no response found', event_type:'info'}
            LoggerJob.perform_async(audit_trails_attributes, {}, fax_record.to_json)
            # HelperMethods::Logger.app_logger('info', 'fax_response: no response found')

          end
        rescue Exception => e

          audit_trails_attributes = {action: 'workflow', actor:  Etc.getlogin, actor_type: 0, event: "fax_response: #{e.message}", event_type:'error'}
          LoggerJob.perform_async(audit_trails_attributes, {error: e.message, status: 'F'})
          # HelperMethods::Logger.app_logger('error', "fax_response: #{e.message}")

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

          audit_trails_attributes = {action: 'workflow', actor:  Etc.getlogin, actor_type: 0, event: "send_fax_status: #{e.message}", event_type:'error'}
          LoggerJob.perform_async(audit_trails_attributes, {error: e.message, status: 'F'})
          # HelperMethods::Logger.app_logger('error', "send_fax_status: #{e.message}")

          service_alive?
          return {}
        end
      end

      def final_response_to_client
        records_groups = FaxRecord.not_send_to_client
        records_groups.each do |server_id, records|
          callback_server = CallbackServer.find(server_id)

          audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "total #{records.size} records for #{callback_server.name}", event_type:'info'}
          LoggerJob.perform_async(audit_trails_attributes, {})
          # HelperMethods::Logger.app_logger('info', "total #{records.size} records for #{callback_server.name}")

          array_of_records =  prepare_client_date(records)
          if array_of_records.blank?

            audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: 'No responses for faxes found', event_type:'info'}
            LoggerJob.perform_async(audit_trails_attributes, {})
            # HelperMethods::Logger.app_logger('info', 'sendback_final_response_to_client: No responses for faxes found')

          else
            array_in_batches = array_of_records.each_slice(ENV['max_records_send_to_client'].to_i).to_a
            array_in_batches.each do |batch_of_records|
              begin

                audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "#{Time.now} posting #{batch_of_records.size} records to #{callback_server.name}", event_type:'info'}
                LoggerJob.perform_async(audit_trails_attributes, {})
                # HelperMethods::Logger.app_logger('info', "#{Time.now} posting #{batch_of_records.size} records to #{callback_server.name}")

                url = URI(callback_server.update_url+'/eFaxService/OutboundDispositionService.svc/Receive')
                response = HTTParty.post(url, body: batch_of_records.to_json, headers: { 'Content-Type' => 'application/json' } )

                audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "#{Time.now} end posting", event_type:'info'}
                LoggerJob.perform_async(audit_trails_attributes, {})
                # HelperMethods::Logger.app_logger('info', "#{Time.now} end posting")

                if response.present? && response.code == 200
                  result = JSON.parse(response)
                  success_ids = []
                  result.each do |r|
                    if r['Message'] == 'Success'
                      success_ids << r['Fax_Id']
                      FaxRecord.find(r['Fax_Id']).update_attributes(sendback_final_response_to_client: 1)
                    end
                  end

                  audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "successfully updated: #{success_ids}", event_type:'info'}
                  LoggerJob.perform_async(audit_trails_attributes, {})
                  # HelperMethods::Logger.app_logger('info', "successfully updated: #{success_ids}")

                else

                  audit_trails_attributes = {action: 'workflow', actor:  Etc.getlogin, actor_type: 0, event: "response error(#{response})", event_type:'error'}
                  LoggerJob.perform_async(audit_trails_attributes, {})
                  # HelperMethods::Logger.app_logger('error', "final_response_to_client: response error(#{response})")

                end
              rescue Exception => e

                audit_trails_attributes = {action: 'workflow', actor:  Etc.getlogin, actor_type: 0, event: "Error while posting final response(#{e.message})", event_type:'error'}
                LoggerJob.perform_async(audit_trails_attributes, {error: e.message, status: 'F'})
                # HelperMethods::Logger.app_logger('error', "final_response_to_client: Error while posting final response(#{e.message})")

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
            fax_duration: record.fax_duration,
            f_status_code: record.is_success == 't' ? 1 : 2,
            f_status_desc: record.is_success == 't' ? 'Success' : 'Failure',
          }
          array_of_records.push(new_record) unless record.in_any_queue?
        end
        array_of_records
      end

      def fax_vendor_up?
        conn = Faraday.new(url: FAX_SERVER_URL, ssl: { ca_file: 'C:/Ruby200/cacert.pem' }  ) do |faraday|
          faraday.request  :url_encoded
          faraday.response :logger
          faraday.adapter Faraday.default_adapter
        end
        token = get_token()
        parts = ["receiveinboundfax?", "token=#{CGI.escape(token)}", "ApiKey=#{CGI.escape(APIKEY)}", "StartDateUTC=#{Date.today.beginning_of_month}", "EndDateUTC=#{Date.today}", "MaxItems=1",]
        path = "/api/" + parts.join("&")
        begin
          response = conn.get path do |req|
            req.body = {}
          end
          return true
        rescue Exception => e
          audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "fax_vendor_up?: #{e.message}", event_type:'error'}
          LoggerJob.perform_async(audit_trails_attributes, {error: e.message})
          # HelperMethods::Logger.app_logger('error', "fax_vendor_up?: #{e.message}")
          return false
        end
      end

      def service_alive?
        if fax_vendor_up?
          unless VendorStatus.service_up?
            audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "FaxService is up #{Time.now}", event_type:'info'}
            LoggerJob.perform_async(audit_trails_attributes, {})
            # HelperMethods::Logger.app_logger('info', "FaxService is up #{Time.now}")
            VendorStatus.create!(service: 'up')
          end
          return true
        else
          unless VendorStatus.service_down?
            audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "FaxService is down #{Time.now}", event_type:'info'}
            LoggerJob.perform_async(audit_trails_attributes, {})
            # HelperMethods::Logger.app_logger('info', "FaxService is down #{Time.now}")
            VendorStatus.create!(service: 'down')
          end
          return false
        end
      end
    end
  end
end
