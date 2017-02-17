# require 'lib/doxifer.rb'
USERNAME = "ealzubaidi"#Enter a valid username
APIKEY = "817C7FD99D6146B89BEA88BA5B1E48DE"#Enter a valid ApiKey
VECTOR = "x49e*wJVXr8BrALE"
ENCRYPTIONKEY = "gZ!LaHKAmmuXd7AMamtPqIepQ7RMsbJ3"#Enter a valid encryptionkey
FAX_SERVER_URL = "https://api.sfaxme.com"
require 'faraday'
require 'pp'
require 'time'
require 'json'
  # strat
  require 'openssl'
require "base64"
class Doxipher
#:iv =>  #Pass in a 16 byte value. Defaults to 16 0 bytes which is not good. class Doxipher
  def initialize( key, options = {} )
      @base64 = options[:base64] || false
      @key = key.clone
      #@iv = options[:iv] || "\0" * 16
  @iv = 'x49e*wJVXr8BrALE'
  end
  def encrypt( plain = nil, &block )
      if @base64
          Base64.encode64( cipher( plain, false, &block ))
      else
          cipher( plain, false, &block )
      end
  end
  def decrypt( cipher_text = nil, &block )
      cipher(cipher_text, true, &block)
  end
  def <<( data)
      @data << @cipher.update( decode_if_needed(data) )
  end
  private
  def decode_if_needed(data)
      @base64 && @decrypt ? Base64.decode64(data) : data
  end
  def cipher( data = nil, _decrypt = false, &block )
      @decrypt = _decrypt
      @cipher = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
      if _decrypt
          @cipher.decrypt
      else
          @cipher.encrypt
      end
      @cipher.key = @key
      @cipher.iv = @iv
      if block_given?
          @data = ''
          block.call self
      else
          @data = @cipher.update decode_if_needed(data) rescue nil
          @data = data if @data.nil?
      end
      @data << @cipher.final
      @data
  end
end
# ending
def get_token
  timestr = Time.now.utc.iso8601()
  raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
  dox = Doxipher.new(ENCRYPTIONKEY, {:base64=>true})
  cipher = dox.encrypt(raw)
  return cipher
end
def send_fax(params)
  #1. validate
  result, error = Fax.validate(params)
  if !result
    return error
  end
  #2. create fax_request
  fax_request = FaxRequest.new(params)
  fax_request.fax_send_date = Time.now
  fax_request.save!
  #3. send fax
  response = s_fax_send(fax_request)
  #4. update fax_request
  fax_request.update_all(status: response[body][status], message: response[body][message], queue_id: response[body][queue_id], fax_vendor_confirm_date: response[body][fax_vender_confirm_date])
  #5. create response_json
  response_json = create_response_json(fax_request)
  #6. return 5
  render json: response_json
end
def create_response_json(fax_request)
  hash = {fax_number: fax_request.fax_number, file_name: fax_request.file_nam}
  return hash
def send_fax(fax_number,file_name,recipient_name)
  tid = nil
  conn = Faraday.new(:url => FAX_SERVER_URL, :ssl => { :ca_file => 'C:/Ruby200/cacert.pem' }  ) do |faraday|#Certificate required
    conn = Faraday.new(:url => FAX_SERVER_URL) do |faraday|# None SSL
      faraday.request :multipart                # checks for files in the payload, otherwise leaves everything untouched
    faraday.request  :url_encoded            # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter Faraday.default_adapter  # make requests with Net::HTTP
  end
  #pp conn
  token = get_token()
  parts = ["sendfax?",
           "token=#{CGI.escape(token)}",
           "ApiKey=#{CGI.escape(APIKEY)}",
           "RecipientFax=#{fax_number}",
           "RecipientName=#{recipient_name}",
           "OptionalParams=&"
          ]
  path = "/api/" + parts.join("&")
  # request.update(fax_send_date: Time.now)
  response = conn.post path do |req|
       req.body = {}
       req.body['file'] = Faraday::UploadIO.new(file_name, 'application/notepad', 'test22.txt') # test3 is the file that we tring to send in the fax
  end
  pp response
end
  #response.update(fax_vendor_confirm_date: response.date)
  #response_json = {fax_number:@fax_request.fax_number,file_name:@fax_request.file_name , recipient_name:@fax_request.recipient_name ,client_receipt_date:@fax_request.receipt_date, fax_send_date:@fax_request.fax_send_date , fax_vendor_confirm_date:@fax_request.fax_vender_confirm_date , message:@fax_request.message , queue_id:@fax_request.queue_id ,status:@fax_request_status response(issuccess) == true}
  #if (!response.is_success)
   # response_json[:status] = false
  #else
    #response_json[:status] = true
  #end
  #response_json[:message] = response.message
  #render json: response_json
  #response_json[:message] = response.message
  #render json: response_json
