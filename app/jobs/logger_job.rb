include Sidekiq::Worker

class LoggerJob
  sidekiq_options queue: 'logger'

  def perform(audit_trails_attributes, extended_params, object=nil)
    data = LoggerService.message(audit_trails_attributes, extended_params, object)
    response = LoggerService.logger_call(data)
    unless response.code == '200'
      raise response.body
    end
  end
end
