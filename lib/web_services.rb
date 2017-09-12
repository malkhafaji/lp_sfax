require 'zip'
module  WebServices
  class Web
    class << self
      def file_path(file_key)
        url="#{ENV['file_service_path']}/api/v1/documents/download?keys=#{file_key.join(",")}"
        files_dir = (FileUtils.mkdir_p "#{Rails.root}/tmp/#{SecureRandom.hex}/").join(",")
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
        return Dir["#{files_dir}/*"], files_dir
      end

      # call to Client and change fax service status on/off
      def client_fax_service_status(state)
        HelperMethods::Logger.app_logger('info', "==>Sending fax service status to client: #{state}")
        begin
          CallbackServer.all.each do |server|
            url = URI(server.url + "/DataAccessService/sFaxService.svc/UpdateFaxServiceStatus?strFaxStatus=#{state}&modify_e_sk=0/")
            url.port = 9012
            http = Net::HTTP.new(url.host, url.port)
            http.use_ssl = true
            request = Net::HTTP::Put.new(url)
            response = http.request(request)
          end
        rescue Exception => e
          HelperMethods::Logger.app_logger('error', "==>Sending fax service status to client: #{e.message}")
        end
      end
    end
  end
end
