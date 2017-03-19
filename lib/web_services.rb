module  WebServices
  def aws_response(file_id)
    url="http://localhost:3000/api/v1/documents/#{file_id}"        
    response = HTTParty.get(url)        
    responsebody = JSON.parse(response.body)
    return responsebody    
  end 
  
  def file_path(file_id)
    res_json = aws_response(file_id) 
    file_url = res_json["file"]["url"]
    file_name = File.basename(file_url)
    system("wget #{file_url} -P #{Rails.root}/tmp/fax_files/fax_file_#{file_id}")
    "#{Rails.root}/tmp/fax_files/fax_file_#{file_id}/#{file_name}"
  end
  
end