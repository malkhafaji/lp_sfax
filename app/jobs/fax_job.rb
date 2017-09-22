include Sidekiq::Worker

class FaxJob
  sidekiq_options queue: 'send_fax'

  def perform(fax_id)
    HelperMethods::Logger.app_logger('info', "==> Performing fax_job with fax ID: #{fax_id}")
    FaxServices::Fax.send_now(fax_id)
  end

end
