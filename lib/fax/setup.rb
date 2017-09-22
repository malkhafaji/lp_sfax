module Fax
  module Setup
    def self.callback_server
      servers_list = YAML.load(File.read('lib/fax/servers.yml'))
      servers_list.each do |s|
        callback_server = CallbackServer.where(name: s[:name], url: s[:url], update_url: s[:update_url]).first_or_create
      end
    end
  end
end
