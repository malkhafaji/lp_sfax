include Sidekiq::Worker

class LoggerJob
  sidekiq_options queue: 'logger'

  def perform(fax_id)
  #	HelperMethods::Logger.app_logger('info', "Logging Fax with fax ID: #{fax_id}")
  #  fax_record = FaxRecord.find(fax_id)
  #  url = URI(fax_record.callback_server.url+'/DataAccessService/sFaxService.svc/InsertFaxes')
  #  url.port = fax_record.callback_server.insert_port
  #  http = Net::HTTP.new(url.host, url.port)
  #  data = {
  #    recipient_name: fax_record.recipient_name
  #    recipient_number: fax_record.recipient_number
  #    FaxDispositionURL: fax_record.params['FaxDispositionURL']
  #    Attachments: fax_record.params['Attachments']
  #    e_sk: fax_record.callback_param['e_sk']
  #    let_sk: fax_record.callback_param['let_sk']
  #    type_cd_sk: fax_record.callback_param['type_cd_sk']
  #    priority_cd_sk: fax_record.callback_param['priority_cd_sk']
  #  }
  #  request = Net::HTTP::Post.new(url, {'Content-Type' => 'application/json'})
  #  request.body = data.to_json
  #  response = http.request(request)
  #  if response.present? && response.code == '200'
  #    HelperMethods::Logger.app_logger('info', "Logger: #{data.to_json}")
  #    HelperMethods::Logger.app_logger('info', "Logger response: #{response.body}")
  #  else
  #    HelperMethods::Logger.app_logger('error', response.inspect)
  #    raise response.inspect
  #  end
  end
end
