module HelperMethods

  def app_logger(type, e, methodname)
      case type
       when type = 'error'
            NotificationMailer.sys_error(e.message, methodname).deliver
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
