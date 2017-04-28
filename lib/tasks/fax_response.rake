require "./app/controllers/concerns/doxifer.rb"
MAX_FAX_RESPONSE_CHECK_TRIES = ENV['max_fax_response_check_tries']

# getting token
def get_token
  timestr = Time.now.utc.iso8601()
  raw ="Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
  dox = Doxipher.new(ENCRYPTIONKEY, {:base64=>true})
  cipher = dox.encrypt(raw)
  return cipher
end

# Checking which fax sent and which not by the SendFaxQueueId and max_fax_response_check_tries, if not send it then send it
desc 'check_fax_response'
task :check_fax_response => :environment do
  fax_requests_queue_ids = FaxRecord.where("fax_date_utc is null and SendFaxQueueId is not null and (max_fax_response_check_tries is null OR max_fax_response_check_tries < #{MAX_FAX_RESPONSE_CHECK_TRIES})").pluck(:SendFaxQueueId)
  fax_requests_queue_ids.each do |fax_requests_queue_id|
    begin
      fax_response(fax_requests_queue_id)
      puts 'OK'
    rescue
      pp "error requesting status for fax #{fax_requests_queue_id}"
      fax_record = FaxRecord.find_by(SendFaxQueueId: fax_requests_queue_id)
      fax_record.update_attributes(max_fax_response_check_tries: fax_record.max_fax_response_check_tries.to_i + 1)
    end
  end
end

# Getting the response for certain fax defained by the SendFaxQueueId
def  fax_response(fax_requests_queue_id)
  response = send_fax_status(fax_requests_queue_id)
  parse_response = response["RecipientFaxStatusItems"][0]
  fax_record = FaxRecord.find_by_SendFaxQueueId(fax_requests_queue_id)
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
      message:             response["message"],
      result_code:         parse_response['ResultCode'],
      result_message:      result_message,
      fax_duration:        fax_duration
      )
end

def calculate_duration(t1,t2)
  return ((t2 - t1) / 60.0).round(2)
end
# Sending the Fax_Queue_Id to get the status
def send_fax_status(fax_requests_queue_id)
  conn = Faraday.new(:url => FAX_SERVER_URL, :ssl => { :ca_file => 'C:/Ruby200/cacert.pem' }  ) do |faraday|
    faraday.request  :url_encoded
    # faraday.response :logger
    faraday.adapter Faraday.default_adapter
  end
  token = get_token()
  parts = ["sendfaxstatus?",
    "token=#{CGI.escape(token)}",
    "ApiKey=#{CGI.escape(APIKEY)}",
  "SendFaxQueueId=#{(fax_requests_queue_id)}"]
  path = "/api/"+parts.join("&")

  response = conn.get path do |req|
    req.body = {}
  end
  return JSON.parse(response.body)
end


# Sending final response as array of jsons to the client for all sent faxes
desc "Sending final response as array of jsons to the client for all sent faxes "
task :sendback_final_response_to_client => :environment do
  records_groups = FaxRecord.where(sendback_final_response_to_client: 0).where.not(send_fax_queue_id: nil).group_by(&:callback_url)
  records_groups.each do |url, records|
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
        Vendor_confirm_date: record.vendor_confirm_date,
        ResultCode: record.result_code,
        fax_duration: record.fax_duration
      }
      array_of_records.push(new_record)
    end
    if array_of_records.blank?
      puts ' No responses for faxes found '
    else
      begin
        response = HTTParty.post(url,
          body: array_of_records.to_json,
          headers: { 'Content-Type' => 'application/json' } )
        unless response.nil? || response.code != 200
          result = JSON.parse(response)
          result.each do |r|
            if r['Message'] == 'Success'
              FaxRecord.find(r['Fax_Id']).update_attributes(sendback_final_response_to_client: 1)
            end
          end
        end
      rescue Exception => e
        render json: e.message.inspect
      end    
    end

  end
end
