module HelperMethods
  class Logger
    class << self
  def app_logger(type, e)
     case type
      when type = 'error'
        if Rails.env.production?
           NotificationMailer.app_error(e.message).deliver_later
         end
           Rails.logger.debug "==> error send_fax: #{e.message} <=="
      when type = 'info'
            Rails.logger.debug "==> error send_fax: #{e.message} <=="
      when type = 'debug'
            Rails.logger.debug "==> error send_fax: #{e.message}<=="
      when type = 'warn'
            Rails.logger.warn "==> error send_fax: #{e.message} <=="
       end
      end
    end #self
  end #class
end
