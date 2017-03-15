
  require './app/controllers/concerns/doxifer.rb'
  require 'faraday'
  require 'pp'
  require 'time'
  require 'json'

  # The requirements to connect with Vendor
  USERNAME = 'ealzubaidi'
  APIKEY = '817C7FD99D6146B89BEA88BA5B1E48DE'
  VECTOR = 'x49e*wJVXr8BrALE'
  ENCRYPTIONKEY = 'gZ!LaHKAmmuXd7AMamtPqIepQ7RMsbJ3'
  FAX_SERVER_URL = 'https://api.sfaxme.com'

  # Getting TOKEN
  def get_token
    timestr = Time.now.utc.iso8601()
    raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
    dox = Doxipher.new(ENCRYPTIONKEY, {base64: true})
    cipher = dox.encrypt(raw)
    return cipher
  end

# sending the fax with the parameters fax_number,recipient_name ,attached file_path,fax_id and define either its sent by user call or by initializer call
  def actual_sending(recipient_name, recipient_number, file_path, fax_id, updated_by_initializer)
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
      req.body['file_name'] = Faraday::UploadIO.new("#{file_path}", file_specification(file_path)[0], file_specification(file_path)[1])
    end
    response_result = JSON.parse(response.body)
    fax_record = FaxRecord.find_by(id: fax_id)
    fax_record.update_attributes(
      status:            response_result["isSuccess"],
      message:           response_result["message"],
      SendFaxQueueId:    response_result["SendFaxQueueId"],
      send_confirm_date: response['date'])

    if fax_record.updated_by_initializer == true
      p fax_record
    else
      render json: fax_record
    end

  end

# Getting the File Name , the File Extension and validate the document type
  def file_specification(file_path)
    file_name = File.basename ("#{file_path}").downcase
    file_extension = File.extname (file_name).downcase
    if file_extension  == ".pdf"
      return "application/PDF", file_name
    elsif file_extension == ".txt"
      return "application/TXT", file_name
    elsif file_extension == ".doc"
      return "application/DOC", file_name
    elsif file_extension == ".docx"
      return "application/DOCX", file_name
    elsif file_extension == ".tif"
      return "application/TIF", file_name
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
