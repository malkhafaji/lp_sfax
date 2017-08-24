include Sidekiq::Worker

class FaxJob
  sidekiq_options queue: 'send_fax'

  def perform(recipient_name, recipient_number, attachments, id)
    FaxServices::Fax.send_now(recipient_name, recipient_number, attachments, id)
  end

end
