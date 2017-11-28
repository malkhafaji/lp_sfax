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

      def logger_service_message(entity_id, action_name, event, *extended_params)
        fax_record = FaxRecord.find(entity_id)
        application_name = Rails.application.class.parent_name.capitalize
        ip = Socket.ip_address_list.detect{|intf| intf.ipv4_private?}
        data = {source_app: application_name,
          is_sensitive: true,
          action: action_name,
          actor: "#{application_name}_service_api",
          actor_type: 0,
          event: event[:message],
          event_type: event[:type],
          process_id: Process.pid,
          thread_id: Thread.current.object_id,
          session_id: Thread.current.object_id,
          ip_address: ip.ip_address,
          extended_attributes: extended_params.present? ? true : false,
          extended_params: extended_params,
          entity: {entity_type: application_name,
            entity_id: entity_id,
            client_id: 000,
            recipient_number: fax_record.recipient_number,
            recipient_name: fax_record.recipient_name,
            attachments: fax_record.attachments.count
          }
        }
      end
    end
  end
end
