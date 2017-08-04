require 'fileutils'
include Sidekiq::Worker

class FaxResendWorker

  sidekiq_options queue: 'fax_resend'

  def perform(send_fax_queue_id)
    Rails.logger.debug("==> Resending the fax with send_fax_queue_id= #{send_fax_queue_id} <==")
    FileUtils.rm_rf Dir.glob("#{Rails.root}/tmp/fax_files/*")
    fax_record = FaxRecord.find_by_send_fax_queue_id(send_fax_queue_id)
    attachments_array = fax_record.attachments.pluck('file_key')
    attachments=  WebServices::Web.file_path(attachments_array)
    FaxServices::Fax.actual_sending( fax_record.recipient_name, fax_record.recipient_number, attachments, fax_record.id)
  end

end
