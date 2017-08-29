include Sidekiq::Worker

class InsertFax
  sidekiq_options queue: 'insert_fax'

  def perform(fax_id)
    fax_record = FaxRecord.find_by(id: fax_id)
    begin
      url = URI.parse(fax_record.callback_url)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      data = {
        f_sk:1,
        f_create_e_sk:1,
        f_create_date: fax_record.created_at ,
        f_modify_e_sk:1,
        f_modify_date: fax_record.updated_at,
        let_sk:1,
        f_type_cd_sk:1,
        f_sent_date: Time.now,
        f_priority_cd_sk:1,
        f_fax_number: fax_record.recipient_number,
        f_page_count: 1,
        f_transmission_id: fax_record.send_fax_queue_id,
        f_recipient_csid: 'string',
        f_recipient_company: 'string',
        f_recipient_name: fax_record.recipient_name,
        f_document_id: 'string',
        f_status_code: 000,
        f_status_desc: 'f_status_desc',
        f_error_level: 1,
        f_error_message: 'string',
        f_completion_date: '2017-08-28 17:08:15 +0000',
        f_duration: 0.1,
        f_pages_sent:1,
        f_number_of_retries: fax_record.resend,
        f_notes: 'string',
        f_fax_id: fax_record.id,
      }
      request = Net::HTTP::Post.new(url.path, {'Content-Type' => 'application/json'})
      request.body = data.to_json
      response = http.request(request)
    rescue Exception => e
      HelperMethods::Logger.app_logger('error', e.message)
    end
    unless response.body == 'Fax inserted successfully'
      InsertFax.perform_in((1.minutes, fax_record.id)
    end
  end

end
