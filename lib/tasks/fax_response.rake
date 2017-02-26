require "./app/controllers/concerns/doxifer.rb"
USERNAME = "ealzubaidi"
APIKEY = "817C7FD99D6146B89BEA88BA5B1E48DE"
VECTOR = "x49e*wJVXr8BrALE"
ENCRYPTIONKEY = "gZ!LaHKAmmuXd7AMamtPqIepQ7RMsbJ3"
FAX_SERVER_URL = "https://api.sfaxme.com"
FAXID = "4C459BEB9C2744409D2823403B2F8746"

desc "Getting the fax response "
task :fax_response => :environment do

  fax_response = FaxResponse.new
  response = send_fax_status
  parse_response = response["RecipientFaxStatusItems"][0]
  fax_response.update_attributes(
                                  send_fax_queue_id:   parse_response['SendFaxQueueId'],
                                  is_success:          parse_response['IsSuccess'],
                                  result_code:         parse_response['ResultCode'],
                                  error_code:          parse_response['ErrorCode'],
                                  result_message:      parse_response['ResultMessage'],
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
                                  message:             response["message"],
                                  fax_request_id:      response["isSuccess"]
                                  )
  fax_response.save!

end


# Sending the Fax_Queue_Id to get the status

   def send_fax_status
     conn = Faraday.new(:url => FAX_SERVER_URL, :ssl => { :ca_file => 'C:/Ruby200/cacert.pem' }  ) do |faraday|
       faraday.request  :url_encoded
       faraday.response :logger
       faraday.adapter Faraday.default_adapter
     end

     token = get_token()
     parts = ["sendfaxstatus?",
     "token=#{CGI.escape(token)}",
     "ApiKey=#{CGI.escape(APIKEY)}",
     "SendFaxQueueId=#{FAXID}"]
     path = "/api/"+parts.join("&")

     response = conn.get path do |req|
       req.body = {}
     end
     return JSON.parse(response.body)
   end

# getting token
   def get_token
     timestr = Time.now.utc.iso8601()
     raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
     dox = Doxipher.new(ENCRYPTIONKEY, {:base64=>true})
     cipher = dox.encrypt(raw)
     return cipher
   end
