class NormalWorker
  include Sidekiq::Worker
  sidekiq_options queue: "default"

  def perform( recipient_name, recipient_number, attachment_from_params, fax_record_id )
    original_file_name, attachments_array = get_attachments(attachment_from_params)
    FaxServices::Fax.actual_sending( recipient_name, recipient_number, attachments_array, fax_record_id )
    $fax_service_status = nil
  end

  def get_attachments(array)
    original_file_name = ''
    attachments = []
    array.each_with_index do |file_info|
      file_info = WebServices::Web.file_path(file_info[0], file_info[1])
      attachments << file_info[0]
      original_file_name += file_info[1]
    end
    return original_file_name, attachments
  end
end
