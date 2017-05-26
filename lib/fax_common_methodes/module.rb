# require './app/controllers/concerns/doxifer.rb'
# require 'faraday'
# require 'pp'
# require 'time'
# require 'json'
# require 'fileutils'
# require './lib/web_services.rb'
# include WebServices
# # The requirements to connect with Vendor
# USERNAME = ENV['username']
# APIKEY = ENV['APIkey']
# VECTOR = ENV['vector']
# ENCRYPTIONKEY = ENV['encryptionkey']
# FAX_SERVER_URL = ENV['fax_server_url']
#
# # Getting TOKEN
# def get_token
#   timestr = Time.now.utc.iso8601()
#   raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
#   dox = Doxipher.new(ENCRYPTIONKEY, {base64: true})
#   cipher = dox.encrypt(raw)
#   return cipher
# end
#
# # sending the fax with the parameters fax_number,recipient_name ,attached file_path,fax_id and define either its sent by user call or by initializer call
# def actual_sending(recipient_name, recipient_number, attachments, fax_id)
#   begin
#     tid = nil
#     conn = Faraday.new(url: FAX_SERVER_URL, ssl: { ca_file: 'C:/Ruby200/cacert.pem' }  ) do |faraday|
#       faraday.request :multipart
#       faraday.request  :url_encoded
#       faraday.response :logger
#       faraday.adapter Faraday.default_adapter
#     end
#     token = get_token()
#     parts = ["sendfax?",
#       "token=#{CGI.escape(token)}",
#       "ApiKey=#{CGI.escape(APIKEY)}",
#       "RecipientFax=#{recipient_number}",
#       "RecipientName=#{recipient_name}",
#     "OptionalParams=&" ]
#     path = "/api/" + parts.join("&")
#     response = conn.post path do |req|
#       req.body = {}
#       attachments.each_with_index do |file, i|
#         req.body["file_name#{i}"] = Faraday::UploadIO.new("#{file}", file_specification(file)[0], file_specification(file)[1])
#       end
#     end
#     response_result = JSON.parse(response.body)
#     fax_record = FaxRecord.find_by(id: fax_id)
#     fax_record.update_attributes(
#       status:            response_result["isSuccess"],
#       message:           response_result["message"],
#       send_fax_queue_id:    response_result["SendFaxQueueId"],
#       send_confirm_date: response['date'])
#     FileUtils.rm_rf Dir.glob("#{Rails.root}/tmp/fax_files/*")
#     if fax_record.send_fax_queue_id.nil?
#       Rails.logger.debug "==> error send_fax_queue_id is nil: #{response_result} <=="
#       fax_record.update_attributes(is_success: false, message: 'Fax request is complete', result_message: 'Transmission not completed', error_code: '1515101', result_code: '7001', status: false, is_success: false)
#     end
#     sendback_initial_response_to_client(fax_record)
#   rescue
#     fax_record.update_attributes(is_success: false, message: 'Fax request is complete', result_message: 'Transmission not completed', error_code: '1515101', result_code: '7001', status: false, is_success: false)
#     Rails.logger.debug "==> Error actual_sending: #{fax.id} <=="
#   end
# end
# # Getting the File Name , the File Extension and validate the document type
# def file_specification(file_path)
#   file_name = File.basename ("#{file_path}").downcase
#   file_extension = File.extname (file_name).downcase
#   accepted_extensions = [".tif", ".xls", ".doc", ".pdf", ".docx", ".txt", ".rtf", ".xlsx", ".ppt", ".odt", ".ods", ".odp", ".bmp", ".gif", ".jpg", ".png"]
#    if accepted_extensions.include?(file_extension)
#      return "application/#{file_extension}", file_name
#    else
#     return false
#    end
# end
#
# # search and find all faxes without Queue_id (not sent yet) and send them by call from the initializer (when the server start)
# def sending_faxes_without_queue_id
#   attachments= []
#   @original_file_name = ''
#   FaxRecord.where(send_fax_queue_id: nil).each do |fax|
#     begin
#       Attachment.where(fax_record_id:fax.id).each do |file|
#         attachments << file_path(file[:file_id],file[:checksum])
#       end
#       fax.update_attributes( updated_by_initializer: true)
#       actual_sending(fax.recipient_name ,fax.recipient_number, attachments ,fax.id)
#     rescue
#       Rails.logger.debug "==> Error sending_faxes_without_queue_id: #{fax.id} <=="
#     end
#   end
# end
#
# # Sending the initial response to the client after sending the fax
# def sendback_initial_response_to_client(fax_record)
#   client_initial_response = {
#     fax_id: fax_record.id,
#     recipient_name: fax_record.recipient_name,
#     recipient_number: fax_record.recipient_number,
#     attached_fax_file: fax_record.file_path,
#     success:  fax_record.status,
#     message: fax_record.message,
#     status: fax_record.status,
#     result_message: fax_record.result_message,
#   client_receipt_date: fax_record.client_receipt_date}
#   #we should put here the client URL to send the json
#
#   if fax_record.updated_by_initializer == true
#     Rails.logger.debug "==> sendback_initial_response_to_client/updated_by_initializer: #{client_initial_response} <=="
#   elsif fax_record.resend > 0 && fax_record.record_completed == false
#     Rails.logger.debug "==> sendback_initial_response_to_client/Resend: #{client_initial_response} <=="
#   else
#     Rails.logger.debug "==> sendback_initial_response_to_client: #{client_initial_response} <=="
#     client_initial_response
#   end
# end
