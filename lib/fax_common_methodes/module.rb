require './app/controllers/concerns/doxifer.rb'
require 'faraday'
require 'pp'
require 'time'
require 'json'
require 'fileutils'
# The requirements to connect with Vendor
USERNAME = ENV['username']
APIKEY = ENV['APIkey']
VECTOR = ENV['vector']
ENCRYPTIONKEY = ENV['encryptionkey']
FAX_SERVER_URL = ENV['fax_server_url']

# Getting TOKEN
def get_token
  timestr = Time.now.utc.iso8601()
  raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
  dox = Doxipher.new(ENCRYPTIONKEY, {base64: true})
  cipher = dox.encrypt(raw)
  return cipher
end

# sending the fax with the parameters fax_number,recipient_name ,attached file_path,fax_id and define either its sent by user call or by initializer call
def actual_sending(recipient_name, recipient_number, attachments, fax_id, updated_by_initializer)
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

  sendback_initial_response_to_client(fax_record)

end

# Getting the File Name , the File Extension and validate the document type
def file_specification(file_path)
  file_name = File.basename ("#{file_path}").downcase
  file_extension = File.extname (file_name).downcase
  accepted_extensions = [".tif",".xls",".doc",".pdf",".docx",".txt",".rtf",".xlsx",".ppt",".odt",".ods",".odp",".bmp",".gif",".jpg",".png"]
   if accepted_extensions.include?(file_extension)
     return "application/#{file_extension}", file_name
   else
    return false
   end
end

# search and find all faxes without Queue_id (not sent yet) and send them by call from the initializer (when the server start)
def sending_faxes_without_queue_id
  begin
    faxes_without_queue_id = FaxRecord.where("SendFaxQueueId is null")
    faxes_without_queue_id.each do |fax_without_queue_id|
      begin
        actual_sending(fax_without_queue_id.recipient_name, fax_without_queue_id.recipient_number, fax_without_queue_id.file_path,fax_without_queue_id.id, fax_without_queue_id.update_attributes( updated_by_initializer:  true))
      rescue
        pp "error requesting sending for fax #{fax_without_queue_id}"
      end
    end
  rescue
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
    p client_initial_response
  else
    render json: client_initial_response
  end
end
