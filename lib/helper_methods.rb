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

      def logger_service_message(entity, actor, process_info, action_name, event)
        fax_record = FaxRecord.find(entity[:fax_id])
        data = {source_app: Rails.application.class.parent_name,
          is_sensitive: true,  # TODO: WE NEED TO ADD THIS
          action: action_name,
          actor: actor[:actor_name],
          actor_type: actor[:type],
          extended_attributes: true, # TODO: WE NEED TO ADD THIS
          event: event[:message],
          event_type: event[:type],
          process_id: process_info[:process_id],
          thread_id: process_info[:thread_id],
          session_id: process_info[:session_id],
          extended_params: {status: 'Success'}, # TODO: WE NEED TO ADD THIS

        entity: {entity_type: entity[:type],
                entity_id: entity[:id],
                client_id: entity[:client_id],
                recipient_number: fax_record.recipient_number,
                recipient_name: fax_record.recipient_name,
                attachments: fax_record.attachments.count
                }
              }
      end
    end
  end
end
