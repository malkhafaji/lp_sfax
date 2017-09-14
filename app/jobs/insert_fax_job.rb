include Sidekiq::Worker

class InsertFaxJob
  sidekiq_options queue: 'insert_fax'

  def perform(fax_id)
    HelperMethods::Logger.app_logger('info', "==> inserting Fax with ID (#{fax_id}) in to client database ")
    fax_record = FaxRecord.find(fax_id)
    callback_server = CallbackServer.find(fax_record.callback_server_id)
    callback_params = fax_record.callback_param
    begin
      url = URI(callback_server.url+'/DataAccessServic/sFaxService.svc/InsertFaxes/')
      url.port = 9012
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      data = {
        f_create_e_sk: callback_params['e_sk'],
        f_create_date: fax_record.created_at ,
        f_modify_e_sk: callback_params['e_sk'],
        f_modify_date: fax_record.updated_at,
        let_sk: callback_params['let_sk'],
        f_type_cd_sk: callback_params['type_cd_sk'],
        f_sent_date: Time.now,
        f_priority_cd_sk: callback_params['priority_cd_sk'],
        f_fax_number: fax_record.recipient_number,
        f_page_count: 0,
        f_transmission_id: fax_record.send_fax_queue_id,
        f_fax_id: fax_record.id
      }
      request = Net::HTTP::Post.new(url, {'Content-Type' => 'application/json'})
      request.body = data.to_json
      response = http.request(request)
    rescue Exception => e
      HelperMethods::Logger.app_logger('error', "==> #{e.message}")
    end
    begin
      unless response.body == 'Fax inserted successfully'
        InsertFaxJob.perform_in(1.minutes, fax_id)
      end
    rescue Exception => e
      HelperMethods::Logger.app_logger('error',"==> #{e.message}")
    end
  end
end
