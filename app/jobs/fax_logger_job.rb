include Sidekiq::Worker

class FaxLoggerJob
  sidekiq_options queue: 'logger'

  def perform(audit_trails_attributes, extended_params, object=nil)
    data = FaxLoggerService.message(audit_trails_attributes, extended_params, object)
    response = FaxLoggerService.logger_call(data)
    unless response.code == '200'
      raise response.body
    end
  end
end
