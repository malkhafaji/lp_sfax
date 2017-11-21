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

      def logger_service_message(id)
        data = {
          client_id:'0000',
          source_app: ['ISO', 'IQ', 'Fax'],
          is_sensitive: ['true/fasle'],
          action: ['create', 'update','delete', 'service'],
          actor: ['jsmith'],
          actor_type: [0,1,2,3],
          extended_attributes: ['true/false'],
          event: ['the message that we need to log'],
          event_type: ['info', 'error', 'debug', 'warning'],
          process_id:['optional',1212121],
          thread_id:['optional',2121212],
          session_id: ['a3b5d555ef'],
          params: ['any number of attributes key => values'],
          loggerable: {
            type: 'Fax',
            fax_id:01,
            client_id:'01',
            recipient_number:00000000000,
            recipient_name:'test',
          no_of_attachments:0 }
        }
      end
    end
  end
end
