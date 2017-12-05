include Sidekiq::Worker

class LoggerJob
  sidekiq_options queue: 'logger'

  def perform(extended_params, audit_trails_attributes)
    data = LoggerService::Logger.message(extended_params, audit_trails_attributes)
    response = LoggerService::Logger.logger_call(data)
    if response.code == '200'
      # HelperMethods::Logger.app_logger('info', "logger service message: #{data.to_json}")
      # HelperMethods::Logger.app_logger('info', "logger service response: #{response.body}")
    else
      # HelperMethods::Logger.app_logger('error', "LoggerJob: #{response.inspect}")
      raise response.inspect
    end
  end
end
