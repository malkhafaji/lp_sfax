module  WebServices
  def aws_response(file_id,checksum)
    url="#{ENV['file_service_path']}/api/v1/documents/#{file_id}?checksum=#{checksum}"
    response = HTTParty.get(url)
    responsebody = JSON.parse(response.body)
    return responsebody
  end

  def file_path(file_id,checksum)
    res_json = aws_response(file_id,checksum)
    @original_file_name += "#{res_json["original_file_name"]}; "
    file_url = res_json["file"]["url"]
    file_name = File.basename(file_url)
    system("wget #{file_url} -P #{Rails.root}/tmp/fax_files/fax_file_#{file_id}")
    "#{Rails.root}/tmp/fax_files/fax_file_#{file_id}/#{file_name}"
  end

end
