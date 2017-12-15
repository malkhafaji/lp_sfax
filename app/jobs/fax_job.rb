include Sidekiq::Worker

class FaxJob
  sidekiq_options queue: 'send_fax'

  def perform(fax_id)

    audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "Performing fax_job with fax ID: #{fax_id}", event_type:'info'}
    LoggerJob.perform_async(audit_trails_attributes, {fax_id: fax_id})
    # HelperMethods::Logger.app_logger('info', "==> Performing fax_job with fax ID: #{fax_id}")
    FaxServices::Fax.send_now(fax_id)
  end

end
