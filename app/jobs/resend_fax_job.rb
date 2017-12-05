require 'fileutils'
include Sidekiq::Worker

class ResendFaxJob

  sidekiq_options queue: 'resend_fax'

  def perform(fax_id)
    # HelperMethods::Logger.app_logger('info', "==> Resending the fax with ID = #{fax_id} <==")
    FaxServices::Fax.send_now(fax_id)
  end

end
