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
