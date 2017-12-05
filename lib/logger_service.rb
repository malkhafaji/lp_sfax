module LoggerService
  class Logger
    class << self
      def message(extended_params, audit_trails_attributes)
        data = {source_app: Rails.application.class.parent_name.capitalize,
          is_sensitive: true,
          action: audit_trails_attributes[:action],
          actor: audit_trails_attributes[:actor],
          actor_type: audit_trails_attributes[:actor_type],
          event: audit_trails_attributes[:event],
          event_type: audit_trails_attributes[:event_type],
          process_id: audit_trails_attributes[:process_id],
          thread_id: audit_trails_attributes[:thread_id],
          session_id: audit_trails_attributes[:session_id],
          extended_attributes: extended_params.present? ? true : false,
          extended_params: extended_params,
        entity: create_entity(audit_trails_attributes[:entity_id])}
      end

      def logger_call(data)
        url = URI(ENV['LOGGER_SERVICE_HOST'])
        url.port = ENV['LOGGER_SERVICE_PORT']
        http = Net::HTTP.new(url.host, url.port)
        request = Net::HTTP::Post.new(url, {'Content-Type' => 'application/json'})
        request.body = data.to_json
        return http.request(request)
      end

private
      def create_entity(entity_id)
        if entity_id.present?
          fax_record = FaxRecord.find(entity_id)
          {entity_type: 'Fax',
            entity_id: entity_id,
            client_id: fax_record.client_id,
            recipient_number: fax_record.recipient_number,
            recipient_name: fax_record.recipient_name,
          attachments: fax_record.attachments.count}
        else
          {entity_type: 'service'}
        end
      end
    end
  end
end
