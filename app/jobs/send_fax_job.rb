class SendFaxJob < ApplicationJob
  queue_as :default

  def perform(recipient_name, recipient_number, attachments, fax_record_id)
    FaxServices::Fax.actual_sending(recipient_name, recipient_number, attachments, fax_record_id)
  end
end
