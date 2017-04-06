  require "./app/controllers/concerns/doxifer.rb"
  MAX_FAX_RESPONSE_CHECK_TRIES = 20

  # getting token
  def get_token
    timestr = Time.now.utc.iso8601()
    raw ="Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
    dox = Doxipher.new(ENCRYPTIONKEY, {:base64=>true})
    cipher = dox.encrypt(raw)
    return cipher
  end

# Checking which fax sent and which not by the SendFaxQueueId and max_fax_response_check_tries, if not send it then send it
desc "check_fax_response "
  task :check_fax_response => :environment do
    fax_requests_queue_ids = FaxRecord.where("fax_date_utc is null and SendFaxQueueId is not null and (max_fax_response_check_tries is null OR max_fax_response_check_tries < #{MAX_FAX_RESPONSE_CHECK_TRIES})").pluck(:SendFaxQueueId)
    fax_requests_queue_ids.each do |fax_requests_queue_id|
      begin
        fax_response(fax_requests_queue_id)
        p FaxRecord.find_by(:SendFaxQueueId => fax_requests_queue_id)
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
    fax_record = FaxRecord.find_by(:SendFaxQueueId => fax_requests_queue_id)

    FaxRecord.update_all(
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
    message:             response["message"])
    fax_record.save!
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
        sendback_final_responses = FaxRecord.where("sendback_final_response_to_client is 0 and send_fax_queue_id is not null")
        array_of_jsons = []
        sendback_final_responses.each do |sendback_final_response|
                      x= {
                        'Fax_ID': sendback_final_response.id,
                        'Recipient_Name': sendback_final_response.recipient_name,
                        'Recipient_Number': sendback_final_response.recipient_number,
                        'Attached_Fax_File': sendback_final_response.file_path,
                        'is_success': sendback_final_response.is_success,
                        'initial_Message': sendback_final_response.message,
                        'Final_Message': sendback_final_response.result_message,
                        'Sender_Number': sendback_final_response.sender_fax,
                        'Number_of_pages': sendback_final_response.pages,
                        'Number_of_attempts': sendback_final_response.attempts,
                        'Error_code': sendback_final_response.error_code,
                        'Client_receipt_date': sendback_final_response.client_receipt_date,
                        'Send_confirm_date': sendback_final_response.fax_date_utc,
                        'Vendor_confirm_date': sendback_final_response.vendor_confirm_date
                      }
                      array_of_jsons.push(x)
                      sendback_final_response.update_attributes(sendback_final_response_to_client: 1)
        end
            if array_of_jsons.blank?
              p ' No responses for faxes found '
            else
              url = 'https://dhp-efax-q.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive'
              @result = HTTParty.post(url,
              body: array_of_jsons.to_json,
              headers: { 'Content-Type' => 'application/json' } )
            end
  end
