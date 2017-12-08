module LoggerService
  class << self

    def message(audit_trails_attributes, extended_params, entity_object)
      build_audit_trails(audit_trails_attributes).merge({
        extended_attr: extended_params.present? ? true : false,
        extended_attr_hash: extended_params,
      entity: create_entity(entity_object)})
    end

    def logger_call(data)
      url = URI(ENV['LOGGER_SERVICE_HOST'] + '/api/v1/loggables')
      http = Net::HTTP.new(url.host)
      request = Net::HTTP::Post.new(url, {'Content-Type' => 'application/json'})
      request.body = data.to_json
      return http.request(request)
    end

    private
    def build_audit_trails(audit_trails_attributes)
      {source_app: Rails.application.class.parent_name,
        is_sensitive: true,
        action: audit_trails_attributes['action'],
        actor: audit_trails_attributes['actor'],
        actor_type: audit_trails_attributes['actor_type'],
        event: audit_trails_attributes['event'],
        event_type: audit_trails_attributes['event_type'],
        process_id: Process.pid,
        thread_id: Thread.current.object_id,
        session_id: Thread.current.object_id,
      ip_address: Socket.ip_address_list[4]}
    end

    def create_entity(entity_object)
      hash = {entity_type: 'fax'}
      if entity_object
        json_hash = JSON.parse(entity_object)
        if json_hash['id']
          hash.merge!({entity_id: json_hash['id'],
            client_id: json_hash['client_id'],
            recipient_number: json_hash['recipient_number'],
            recipient_name: json_hash['recipient_name']
          })
        else
          hash.merge!({client_id: json_hash['client_id']})
        end
      end
      hash
    end

  end
end
