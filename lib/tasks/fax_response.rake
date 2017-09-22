# Checking which fax sent and which not by the SendFaxQueueId and max_fax_response_check_tries, if not send it then send it
desc 'check_fax_response'
task check_fax_response: :environment do
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
task sendback_final_response_to_client: :environment do
  FaxServices::Fax.old_sendback_final_response_to_client
  FaxServices::Fax.final_response_to_client
end
