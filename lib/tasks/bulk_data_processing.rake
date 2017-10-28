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

  task add_callback_server_id: :environment do
    h = {"https://bcbsne-efax.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://bcbsne-efax.discoveryhealthpartners.com",
    "https://humana-efax.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://humana-efax.discoveryhealthpartners.com",
    "https://para-efax.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://para-efax.discoveryhealthpartners.com",
    "https://ah-efax.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://ah-efax.discoveryhealthpartners.com",
    "https://dhp-efax.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://dhp-efax.discoveryhealthpartners.com",
    "https://MC1-efax.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://mc1-efax.discoveryhealthpartners.com",
    "https://fchp-efax.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://fchp-efax.discoveryhealthpartners.com",
    "https://UG-efax.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://ug-efax.discoveryhealthpartners.com",
    "https://dhp-efax-cob.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://dhp-efax-cob.discoveryhealthpartners.com",
    "https://dhp-efax-q.discoveryhealthpartners.com/eFaxService/OutboundDispositionService.svc/receive": "https://dhp-efax-q.discoveryhealthpartners.com",
    "https://para-efax.discoveryhealthpartners.com": "https://para-efax.discoveryhealthpartners.com"}

    h.each do |k,v|
      callback_server_id = CallbackServer.find_by_update_url(v).id
      puts 'find ' + callback_server_id.to_s
      FaxRecord.where(callback_url: k, callback_server_id: nil).update_all(callback_server_id: callback_server_id)
    end
  end
end
