require 'fileutils'
include Sidekiq::Worker

class ResendFaxJob

  sidekiq_options queue: 'resend_fax'

  def perform(fax_id)

    audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "Resending the fax with ID = #{fax_id}", event_type:'info'}
    FaxLoggerJob.perform_async(audit_trails_attributes, {fax_id: fax_id})
    # HelperMethods::Logger.app_logger('info', "==> Resending the fax with ID = #{fax_id} <==")

    FaxServices::Fax.send_now(fax_id)
  end

end
