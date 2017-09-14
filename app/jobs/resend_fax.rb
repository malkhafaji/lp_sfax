include Sidekiq::Worker

class ResendFax

  sidekiq_options queue: 'resend_fax'

  def perform(id)
    Rails.logger.debug("==> Resending the fax with ID = #{id} <==")
    fax_record = FaxRecord.find(id)
    FaxServices::Fax.actual_sending( fax_record.recipient_name, fax_record.recipient_number, fax_record.id)
  end

end
