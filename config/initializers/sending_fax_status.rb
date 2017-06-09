
# require './lib/fax_common_methodes/module.rb'
  unless defined?(::Rake)
    FaxServices::Fax.sending_faxes_without_queue_id # Calling the method to check all the faxes without the Queue Id (which mean not sent yet)
    Rails.logger.debug "==> run send_fax_status initializer <=="
  end
