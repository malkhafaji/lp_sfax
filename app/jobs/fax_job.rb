include Sidekiq::Worker

class FaxJob
  sidekiq_options queue: 'send_fax'

  def perform(recipient_name, recipient_number, fax_id, callback_params)
    FaxServices::Fax.send_now(recipient_name, recipient_number, fax_id, callback_params)
  end

end
