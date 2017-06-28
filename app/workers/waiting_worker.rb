class WaitingWorker
  include Sidekiq::Worker
  sidekiq_options queue: "waiting"
  def perform( recipient_name, recipient_number, attachment_from_params, fax_record_id )
    FaxServices::Fax.actual_sending( recipient_name, recipient_number, attachment_from_params, fax_record_id )
    $fax_service_status = nil
  end
end
