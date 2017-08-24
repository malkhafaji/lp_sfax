require 'fileutils'
include Sidekiq::Worker

class ResendFaxJob

  sidekiq_options queue: 'resend_fax'

  def perform(id)
    Rails.logger.debug("==> Resending the fax with ID = #{id} <==")
    FileUtils.rm_rf Dir.glob("#{Rails.root}/tmp/fax_files/*")
    fax_record = FaxRecord.find(id)
    attachments_array = fax_record.attachments.pluck('file_key')
    attachments=  WebServices::Web.file_path(attachments_array)
    FaxServices::Fax.send_now( fax_record.recipient_name, fax_record.recipient_number, attachments, fax_record.id)
  end

end
