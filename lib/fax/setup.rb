module Fax
  module Setup
    def self.callback_server
      servers_list = YAML.load(File.read('lib/fax/servers.yml'))
      servers_list.each do |s|
        callback_server = CallbackServer.where(url: s[:url]).first_or_create!
        callback_server.update_attributes(name: s[:name], update_url: s[:update_url], insert_port: s[:insert_port])
      end
    end
  end
end
