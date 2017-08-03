class FaxResendWorker
  include Sidekiq::Worker
  sidekiq_options queue: "fax_resend"

  def perform(send_fax_queue_id)
    fax_record = FaxRecord.find(send_fax_queue_id: send_fax_queue_id)
    FaxServices::Fax.actual_sending(fax_record.recipient_name, fax_record.recipient_number, fax_record.attachments, fax_record.id)
  end

end
