module HelperMethods

  def app_logger(type, e)
      case type
       when type = 'error'
         if Rails.env.production?
            NotificationMailer.sys_error(e.message).deliver
         end
            Rails.logger.debug "==> error send_fax: #{e.message} <=="
       when type = 'info'
             Rails.logger.debug "==> error send_fax: #{e.message} <=="
       when type = 'debug'
             Rails.logger.debug "==> error send_fax: #{e.message} <=="
       when type = 'warn'
             Rails.logger.warn "==> error send_fax: #{e.message} <=="
        end
      end
  end
