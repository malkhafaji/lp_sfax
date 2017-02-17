require './app/controller/concerns/doxifer.rb'
 USERNAME = "ealzubaidi"
 APIKEY = "817C7FD99D6146B89BEA88BA5B1E48DE"
 VECTOR = "x49e*wJVXr8BrALE"
 ENCRYPTIONKEY = "gZ!LaHKAmmuXd7AMamtPqIepQ7RMsbJ3"
 FAX_SERVER_URL = "https://api.sfaxme.com"
 require 'faraday'
 require 'pp'
 require 'time'
 require 'json'

def get_token
  timestr = Time.now.utc.iso8601()
  raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
  dox = Doxipher.new(ENCRYPTIONKEY, {:base64=>true})
  cipher = dox.encrypt(raw)
  return cipher
end

def send_fax(recipient_number,file_path,recipitent_name)
  tid = nil
  conn = Faraday.new(:url => FAX_SERVER_URL, :ssl => { :ca_file => 'C:/Ruby200/cacert.pem' }  ) do |faraday|
    conn = Faraday.new(:url => FAX_SERVER_URL) do |faraday|
      faraday.request :multipart
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end
    #pp conn
    token = get_token()
    parts = ["sendfax?",
    "token=#{CGI.escape(token)}",
    "ApiKey=#{CGI.escape(APIKEY)}",
    "RecipientFax=#{fax_number}",
    "RecipientName=#{recipitent_name}",
    "OptionalParams=&"
    ]
    path = "/api/" + parts.join("&")
    request.update(fax_send_date: Time.now)
    response = conn.post path do |req|
      req.body = {}
      req.body['file'] = Faraday::UploadIO.new(file_name, 'application/notepad', 'test22.txt')
    end
    pp response.nill
    response.update(fax_vendor_confirm_date: response.date)
    response_json = {fax_number:@fax_request.recipient_number,file_name:@fax_request.file_path , recipient_name:@fax_request.recipient_name ,client_receipt_date:@fax_request.receipt_date, fax_send_date:@fax_request.fax_send_date , fax_vendor_confirm_date:@fax_request.fax_vender_confirm_date , message:@fax_request.message , queue_id:@fax_request.queue_id ,status:@fax_request_status response(issuccess) == true}
    #if (!response.is_success)
    # response_json[:status] = false
    #else
    #response_json[:status] = true
    #end

    response_json[:message] = response.message
    render json: response_json
    response_json[:message] = response.message
    render json: response_json
  end
end
