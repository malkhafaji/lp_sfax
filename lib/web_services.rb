require 'zip'
module  WebServices
  class Web
    class << self
      def file_path(file_key)
        url="#{ENV['file_service_path']}/api/v1/documents/download?keys=#{file_key.join(",")}"
        files_dir = (FileUtils.mkdir_p "#{Rails.root}/tmp/fax_files/").join(",")
        response = HTTParty.get(url,follow_redirects: false)
        if response.headers["content-type"] ==  'application/zip'
          File.open("#{files_dir}/zipped_file.zip", "wb") {|f| f.write(response.body) }
          Zip::File.open("#{files_dir}/zipped_file.zip") do |zip_file|
            zip_file.each do |entry|
              entry.extract("#{files_dir}/#{entry.name}")
            end
          end
          FileUtils.rm_rf Dir.glob("#{files_dir}/zipped_file.zip")
        else
          system("wget #{response.headers['location']} -P #{files_dir}")
        end
        Rails.logger.debug("==> Files attached to fax #{Dir["#{Rails.root}/tmp/fax_files/*"]}")
        return Dir["#{Rails.root}/tmp/fax_files/*"]
      end

      # call to Client and change fax service status on/off
      def fax_service_status
        servers_list = CallbackServer.all
        servers_list.each do |server|
          url = URI.parse(server.url+'/faxes/change_status')
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true
          request = Net::HTTP::Get.new(url)
          response = http.request(request)
        end
      end
      
    end
  end
end
