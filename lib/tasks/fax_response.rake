# Checking which fax sent and which not by the SendFaxQueueId and max_fax_response_check_tries, if not send it then send it
desc 'check_fax_response'
task check_fax_response: :environment do
  if VendorStatus.service_up?
    fax_requests_queue_ids = FaxRecord.without_response_q_ids
    if fax_requests_queue_ids.any?

      audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "checking response for #{fax_requests_queue_ids}", event_type:'info'}
      FaxLoggerJob.perform_async(audit_trails_attributes, {fax_requests_queue_ids: fax_requests_queue_ids})
      # HelperMethods::Logger.app_logger('info', "check_fax_response: checking response for #{fax_requests_queue_ids}")

      fax_requests_queue_ids.each do |fax_requests_queue_id|
        begin

          audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "requesting response for #{fax_requests_queue_id}", event_type:'info'}
          FaxLoggerJob.perform_async(audit_trails_attributes, {fax_requests_queue_id: fax_requests_queue_id})
          # HelperMethods::Logger.app_logger('info', "check_fax_response: requesting response for #{fax_requests_queue_id}")

          FaxServices::Fax.fax_response(fax_requests_queue_id)
        rescue Exception => e

          audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "requesting response for #{fax_requests_queue_id}", event_type:'error'}
          FaxLoggerJob.perform_async(audit_trails_attributes, {error: e.message})
          # HelperMethods::Logger.app_logger('error', "check_fax_response: #{e.message}")

          fax_record = FaxRecord.find_by(send_fax_queue_id: fax_requests_queue_id)
          fax_record.update_attributes(max_fax_response_check_tries: fax_record.max_fax_response_check_tries.to_i + 1)
        end
      end
    else

      audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: 'No changes since last task!', event_type:'info'}
      FaxLoggerJob.perform_async(audit_trails_attributes, {})
      # HelperMethods::Logger.app_logger('info', 'check_fax_response: No changes sicne last task!')

    end
  else
    FaxServices::Fax.service_alive?
    exit(false)
  end
end

# Sending final response as array of jsons to the client for all sent faxes
desc 'Sending final response as array of jsons to the client for all sent faxes'
task sendback_final_response_to_client: :environment do
  FaxServices::Fax.final_response_to_client
end
