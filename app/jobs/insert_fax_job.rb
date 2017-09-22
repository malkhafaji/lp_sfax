include Sidekiq::Worker

class InsertFaxJob
  sidekiq_options queue: 'insert_fax'

  def perform(fax_id)
    HelperMethods::Logger.app_logger('info', "==> inserting Fax with ID (#{fax_id}) in to client database ")
    fax_record = FaxRecord.find(fax_id)
    url = URI(fax_record.callback_server.url+'/DataAccessService/sFaxService.svc/InsertFaxes')
    url.port = fax_record.callback_server.insert_port
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    data = {
      f_create_e_sk: fax_record.callback_param['e_sk'],
      f_create_date: "\/Date(#{fax_record.created_at.to_i})\/",
      f_modify_e_sk: fax_record.callback_param['e_sk'],
      f_modify_date: "\/Date(#{fax_record.updated_at.to_i})\/",
      let_sk: fax_record.callback_param['let_sk'],
      f_type_cd_sk: fax_record.callback_param['type_cd_sk'],
      f_sent_date: "\/Date(#{Time.now.to_i})\/",
      f_priority_cd_sk: fax_record.callback_param['priority_cd_sk'],
      f_fax_number: fax_record.recipient_number,
      f_page_count: 0,
      f_transmission_id: fax_record.send_fax_queue_id,
      f_recipient_csid: '',
      f_recipient_company: '',
      f_recipient_name: '',
      f_document_id: fax_record.id,
      f_status_code: fax_record.status == "t" ? 4 : 2,
      f_status_desc: fax_record.status == "t" ? 'Vendor Received' : 'Failure',
      f_error_level: 0,
      f_error_message: fax_record.result_message.present? ? fax_record.result_message : '' ,
      f_completion_date: "\/Date(#{fax_record.updated_at.to_i})\/",
      f_duration: 0,
      f_pages_sent: 0,
      f_number_of_retries: 0,
      f_notes: "This fax was sent via Fax Service API."
      f_fax_id: fax_record.id
    }
    request = Net::HTTP::Post.new(url, {'Content-Type' => 'application/json'})
    request.body = data.to_json
    response = http.request(request)
    if response.present? && response.code == '200'
      HelperMethods::Logger.app_logger('info', "insert fax date: #{data.to_json}")
      HelperMethods::Logger.app_logger('info', "insert fax response: #{response.body}")
    else
      HelperMethods::Logger.app_logger('error', response.inspect)
    end
  end
end
