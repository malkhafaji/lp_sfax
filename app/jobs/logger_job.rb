include Sidekiq::Worker

class LoggerJob
  sidekiq_options queue: 'logger'

  def perform(fax_id)
    data = HelperMethods::Logger.logger_service_message(fax_id)
    url = URI(ENV['LOGGER_SERVICE_HOST'])
    url.port = ENV['LOGGER_SERVICE_PORT']
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    request = Net::HTTP::Post.new(url, {'Content-Type' => 'application/json'})
    request.body = data.to_json
    response = http.request(request)

    if response.code == '200'
      HelperMethods::Logger.app_logger('info', "logger service message: #{data.to_json}")
      HelperMethods::Logger.app_logger('info', "logger service response: #{response.body}")
    else
      HelperMethods::Logger.app_logger('error', "LoggerJob: #{response.inspect}")
      raise response.inspect
    end

  end
end
