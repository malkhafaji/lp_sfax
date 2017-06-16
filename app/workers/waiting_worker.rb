class WaitingWorker
  include Sidekiq::Worker
  sidekiq_options queue: "waiting"
  def perform( recipient_name, recipient_number, attachments, fax_record_id )
    FaxServices::Fax.actual_sending( recipient_name, recipient_number, attachments, fax_record_id )
  end

end
