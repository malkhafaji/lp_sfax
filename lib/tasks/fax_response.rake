# Checking which fax sent and which not by the SendFaxQueueId and max_fax_response_check_tries, if not send it then send it
desc 'check_fax_response'
task :check_fax_response => :environment do
  fax_requests_queue_ids = FaxRecord.without_response_q_ids
  if fax_requests_queue_ids.any?
    HelperMethods::Logger.app_logger('info', "==> checking response for: #{fax_requests_queue_ids}<==")
    fax_requests_queue_ids.each do |fax_requests_queue_id|
      begin
        HelperMethods::Logger.app_logger('info', "==>requesting response for: #{fax_requests_queue_id}<==")
        FaxServices::Fax.fax_response(fax_requests_queue_id)
      rescue Exception => e
        HelperMethods::Logger.app_logger('error', e.message)
        fax_record = FaxRecord.find_by(send_fax_queue_id: fax_requests_queue_id)
        fax_record.update_attributes(max_fax_response_check_tries: fax_record.max_fax_response_check_tries.to_i + 1)
      end
    end
  else
    HelperMethods::Logger.app_logger('info', '==> check_fax_response: No records found to check')
  end
end

# Sending final response as array of jsons to the client for all sent faxes
desc 'Sending final response as array of jsons to the client for all sent faxes'
task :sendback_final_response_to_client => :environment do
  records_groups = FaxRecord.not_send_to_client
  records_groups.each do |server_id, records|
    callback_server = CallbackServer.find(server_id)
    array_of_records = []
    HelperMethods::Logger.app_logger('info', "==> total #{records.size} records for #{callback_server.url} <==")
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
      array_of_records.push(new_record)
    end
    if array_of_records.blank?
      HelperMethods::Logger.app_logger('info', '==> sendback_final_response_to_client: No responses for faxes found <==')
    else
      array_in_batches = array_of_records.each_slice(ENV['max_records_send_to_client'].to_i).to_a
      array_in_batches.each do |batch_of_records|
        begin
          HelperMethods::Logger.app_logger('info', "==> #{Time.now} posting #{batch_of_records.size} records to #{callback_server.url} <==")
          url = URI(callback_server.url+'/eFaxService/OutboundDispositionService.svc/Receive')
          url.port = 9001
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
