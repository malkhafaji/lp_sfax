module SfaxApi
  PATHS = {get_file_by_id: 'https://lp-file-ssharba.c9users.io/api/v1/documents/'}
  
  METHODS = {get: 0, post: 1, put: 2}
  
  def get_response
    uri = URI.parse 'https://lp-file-ssharba.c9users.io/api/v1/documents/'
    puts 'getting......'
    res = Net::HTTP.start(uri.host, uri.port) {|http|
      http.send_request('GET', uri.to_s)
    }
    begin
      json = JSON.parse(res.body)
    rescue JSON::ParserError
      puts "No JSON to parse from response. Status: #{res.code}"
      json = {}

      json['errors'] = res.msg if res.code.to_i >= 400
    end
    
    json[:status] = res.code
    json
  end
end