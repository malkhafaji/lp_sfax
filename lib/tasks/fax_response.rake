
MAX_FAX_RESPONSE_CHECK_TRIES = ENV['max_fax_response_check_tries']

# Checking which fax sent and which not by the SendFaxQueueId and max_fax_response_check_tries, if not send it then send it
desc 'check_fax_response'
task :check_fax_response => :environment do
  fax_requests_queue_ids = FaxRecord.where.not(send_fax_queue_id: nil).where("max_fax_response_check_tries is null OR max_fax_response_check_tries<#{MAX_FAX_RESPONSE_CHECK_TRIES}").pluck(:send_fax_queue_id)
  if fax_requests_queue_ids.any?
    Rails.logger.debug "==> checking response for: #{fax_requests_queue_ids}<=="
    fax_requests_queue_ids.each do |fax_requests_queue_id|
      begin
        Rails.logger.debug "==>requesting response for: #{fax_requests_queue_id}<=="
        FaxServices::Fax.fax_response(fax_requests_queue_id)
      rescue Exception => e
        NotificationMailer.sys_error(e.message).deliver
        Rails.logger.debug "==>error: #{e.message.inspect}<=="
        fax_record = FaxRecord.find_by(send_fax_queue_id: fax_requests_queue_id)
        fax_record.update_attributes(max_fax_response_check_tries: fax_record.max_fax_response_check_tries.to_i + 1)
      end
    end
  else
    Rails.logger.debug '==> check_fax_response: No records found to check'
  end
end

# Sending final response as array of jsons to the client for all sent faxes
desc 'Sending final response as array of jsons to the client for all sent faxes'
task :sendback_final_response_to_client => :environment do
  records_groups = FaxRecord.where(sendback_final_response_to_client: 0).where.not(send_fax_queue_id: nil).group_by(&:callback_url)
  records_groups.each do |url, records|
    array_of_records = []
    Rails.logger.debug "==> total #{records.size} records for #{url} <=="
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
      Rails.logger.debug '==> sendback_final_response_to_client: No responses for faxes found <=='
    else
      array_in_batches = array_of_records.each_slice(ENV['max_records_send_to_client'].to_i).to_a
      array_in_batches.each do |batch_of_records|
        begin
          Rails.logger.debug "==> #{Time.now} posing #{batch_of_records.size} records to #{url} <=="
          response = HTTParty.post(url,
            body: batch_of_records.to_json,
          headers: { 'Content-Type' => 'application/json' } )
          Rails.logger.debug "==> #{Time.now} end posting <=="
          if response.present? && response.code == 200
            result = JSON.parse(response)
            success_ids = []
            result.each do |r|
              if r['Message'] == 'Success'
                success_ids << r['Fax_Id']
                FaxRecord.find(r['Fax_Id']).update_attributes(sendback_final_response_to_client: 1)
              end
            end
            Rails.logger.debug "==> successfully updated: #{success_ids} <=="
          else
            Rails.logger.debug "==> response error: #{response} <=="
          end
        rescue Exception => e
          NotificationMailer.sys_error(e.message).deliver
          Rails.logger.debug "==> post error: #{e.message} <=="
        end
      end
    end
  end
end
