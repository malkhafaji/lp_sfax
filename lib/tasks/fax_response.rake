require "./app/controllers/concerns/doxifer.rb"
USERNAME = "ealzubaidi"
APIKEY = "817C7FD99D6146B89BEA88BA5B1E48DE"
VECTOR = "x49e*wJVXr8BrALE"
ENCRYPTIONKEY = "gZ!LaHKAmmuXd7AMamtPqIepQ7RMsbJ3"
FAX_SERVER_URL = "https://api.sfaxme.com"
FAXID = "4C459BEB9C2744409D2823403B2F8746"

task :fax_response => :environment do

  fax_response = FaxResponse.new
  response = send_fax_status
  fax_response.update_attributes(
                                  send_fax_queue_id:   response["RecipientFaxStatusItems"][0]['SendFaxQueueId'],
                                  is_success:          response["RecipientFaxStatusItems"][0]['IsSuccess'],
                                  result_code:         response["RecipientFaxStatusItems"][0]['ResultCode'],
                                  error_code:          response["RecipientFaxStatusItems"][0]['ErrorCode'],
                                  result_message:      response["RecipientFaxStatusItems"][0]['ResultMessage'],
                                  recipient_name:      response["RecipientFaxStatusItems"][0]['RecipientName'],
                                  recipient_fax:       response["RecipientFaxStatusItems"][0]['RecipientFax'],
                                  tracking_code:       response["RecipientFaxStatusItems"][0]['TrackingCode'],
                                  fax_date_utc:        response["RecipientFaxStatusItems"][0]['FaxDateUtc'],
                                  fax_id:              response["RecipientFaxStatusItems"][0]['FaxId'],
                                  pages:               response["RecipientFaxStatusItems"][0]['Pages'],
                                  attempts:            response["RecipientFaxStatusItems"][0]['Attempts'],
                                  sender_fax:          response["RecipientFaxStatusItems"][0]['SenderFax'],
                                  barcode_items:       response["RecipientFaxStatusItems"][0]['BarcodeItems'],
                                  fax_success:         response["RecipientFaxStatusItems"][0]['FaxSuccess'],
                                  out_bound_fax_id:    response["RecipientFaxStatusItems"][0]['OutBoundFaxId'],
                                  fax_pages:           response["RecipientFaxStatusItems"][0]['FaxPages'],
                                  fax_date_iso:        response["RecipientFaxStatusItems"][0]['FaxDateIso'],
                                  watermark_id:        response["RecipientFaxStatusItems"][0]['WatermarkId'],
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
     return resopnse = JSON.parse(response.body)
   end

# getting token
   def get_token
     timestr = Time.now.utc.iso8601()
     raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
     dox = Doxipher.new(ENCRYPTIONKEY, {:base64=>true})
     cipher = dox.encrypt(raw)
     return cipher
   end
