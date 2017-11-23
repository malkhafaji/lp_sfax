module HelperMethods
  class Logger
    class << self
    def app_logger(type, message)
      case type
        when type = 'error'
          Rails.logger.error message
          NotificationMailer.app_error(message).deliver_later if Rails.env.production?
        when type = 'info'
          Rails.logger.info message
        when type = 'debug'
          Rails.logger.debug message
        when type = 'warn'
          Rails.logger.warn message
        end
      end
    end
  end  
end