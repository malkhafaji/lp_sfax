require 'fileutils'
include Sidekiq::Worker

class ResendFax

  sidekiq_options queue: 'resend_fax'

  def perform(fax_record_id)
    Rails.logger.debug("==> Resending the fax with ID = #{fax_record_id} <==")
    FileUtils.rm_rf Dir.glob("#{Rails.root}/tmp/fax_files/*")
    fax_record = FaxRecord.find_by_id(fax_record_id)
    attachments_array = fax_record.attachments.pluck('file_key')
    attachments=  WebServices::Web.file_path(attachments_array)
    FaxServices::Fax.actual_sending( fax_record.recipient_name, fax_record.recipient_number, attachments, fax_record.id)
  end

end
