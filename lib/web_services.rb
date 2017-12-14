require 'zip'
module  WebServices
  class Web
    class << self
      def file_path(file_key, fax_id)
        files_folder = "#{Rails.root}/tmp/#{fax_id}"
        if Dir.exist?(files_folder)
          if file_key.size == (Dir["#{files_folder}/*"]).size

            audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "Files attached #{Dir["#{files_folder}/*"]} to fax #{fax_id}", event_type:'info'}
            LoggerJob.perform_async(audit_trails_attributes, {files: Dir["#{files_folder}/*"], fax_id: fax_id})
            # HelperMethods::Logger.app_logger('info', "==> Files attached to fax #{Dir["#{files_folder}/*"]}")

            return  Dir["#{files_folder}/*"],files_folder
          else

            audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: 'Missing one or more attachments', event_type:'error'}
            LoggerJob.perform_async(audit_trails_attributes, {files_keys: file_key,fax_id: fax_id})
            # HelperMethods::Logger.app_logger('error', "==> Missing one or more attachments ")

            return [], files_folder
          end
        else
          url="#{ENV['file_service_path']}/api/v1/documents/download?keys=#{file_key.join(",")}"
          files_dir = (FileUtils.mkdir_p "#{Rails.root}/tmp/#{fax_id}/").join(",")
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
          if (Dir["#{files_dir}/*"]).empty?
            audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "No files downloaded for keys #{file_key}", event_type:'error'}
            LoggerJob.perform_async(audit_trails_attributes, {files_keys: file_key})
            # HelperMethods::Logger.app_logger('error', "No files downloaded for keys #{file_key}")

            return [],files_dir
          else
            audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "Files attached to fax #{Dir["#{files_dir}/*"]}", event_type:'info'}
            LoggerJob.perform_async(audit_trails_attributes, {files: Dir["#{files_dir}/*"], fax_id: fax_id})
            # HelperMethods::Logger.app_logger('info', "Files attached to fax #{Dir["#{files_dir}/*"]}")
            return Dir["#{files_dir}/*"], files_dir
          end
        end
      end
      # call to Client and change fax service status on/off
      def client_fax_service_status(state)
        CallbackServer.all.each do |server|
          audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "Sending fax service status to #{server.name}: #{state}", event_type:'info'}
          LoggerJob.perform_async(audit_trails_attributes, {state: state})
          # HelperMethods::Logger.app_logger('info', "Sending fax service status to #{server.name}: #{state}")

          begin
            url = URI(server.url + "/DataAccessService/sFaxService.svc/UpdateFaxServiceStatus?strFaxStatus=#{state}&modify_e_sk=0")
            url.port = server.insert_port
            http = Net::HTTP.new(url.host, url.port)
            request = Net::HTTP::Put.new(url)
            response = http.request(request)
          rescue Exception => e
            audit_trails_attributes = {action: 'workflow', actor: Etc.getlogin, actor_type: 0, event: "Fail to send fax service status to #{server.name}", event_type:'error'}
            LoggerJob.perform_async(audit_trails_attributes, {error: e.message})
            # HelperMethods::Logger.app_logger('error', "Fail to send fax service status to #{server.name}: #{e.message}")
          end
        end
      end
    end
  end
end
