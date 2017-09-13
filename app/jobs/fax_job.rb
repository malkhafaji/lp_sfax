include Sidekiq::Worker

class FaxJob
  sidekiq_options queue: 'send_fax'

  def perform(fax_id)
    FaxServices::Fax.send_now(fax_id)
  end

end
