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
        data = {source_app: 'fax',
          is_sensitive: true,
          action: 'create',
          actor: 'fax_service_api',
          actor_type: 0,
          extended_attributes: true,
          event: 'the message that we need to log',
          event_type: 'info',
          process_id: '1212121',
          thread_id: '121234',
          session_id: 'a3b5d555ef',
          extended_params: {status: 'Success'},
        entity: {entity_type: 'Fax', entity_id: 11, client_id: 12, recipient_number: '12345678912', recipient_name: 'test_name', attachments: 2}}
      end
    end
  end
end
