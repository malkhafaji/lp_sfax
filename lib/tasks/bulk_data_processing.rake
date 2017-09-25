namespace :bulk_data_processing do
  desc 'Generate unique key for documents without key'
  task add_unique_key: :environment do
    Attachment.where.not(checksum: nil).find_each do |a|
      puts "updating file #{a.file_id}, #{a.checksum}"
      url="#{ENV['file_service_path']}/api/v1/documents/get_file_key?file_id=#{a.file_id}&checksum=#{a.checksum}"
      response = HTTParty.get(url)
      res_json = JSON.parse(response.body)
      a.update_attributes(file_key: res_json["unique_key"])
    end
  end


 desc 'loop for old callback_url in fax records'
 task update_callback_url: :environment do
      FaxRecord.where(callback_server_id: nil ).where.not(callback_url: nil).find_each do |fax|
      callback_server = CallbackServer.find_by_update_url(fax.callback_url)
      fax.update_attributes(callback_server_id: callback_server.id)
    end
  end
end
