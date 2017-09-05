include Sidekiq::Worker

class PendingFaxJob
  sidekiq_options queue: 'pending_fax'

  def perform(recipient_name, recipient_number, fax_id, callback_params)
    Rails.logger.debug("==> Pending fax with ID = #{fax_id}")
  end

end
