require './app/controllers/concerns/doxifer.rb'
require 'faraday'
require 'pp'
require 'time'
require 'json'

class FaxRequestsController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  before_action :set_fax_request, only: [:update]

  # The requirements to connect with Vendor
  USERNAME = "ealzubaidi"
  APIKEY = "817C7FD99D6146B89BEA88BA5B1E48DE"
  VECTOR = "x49e*wJVXr8BrALE"
  ENCRYPTIONKEY = "gZ!LaHKAmmuXd7AMamtPqIepQ7RMsbJ3"
  FAX_SERVER_URL = "https://api.sfaxme.com"

  # Getting TOKEN
  def get_token
    timestr = Time.now.utc.iso8601()
    raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
    dox = Doxipher.new(ENCRYPTIONKEY, {:base64=>true})
    cipher = dox.encrypt(raw)
    return cipher
  end


  # Sending fax
  def send_fax
    recipient_number = params["recipient_number"]
    file_path = params["file_path"]
    recipient_name = params["recipient_name"]
    fax_request =FaxRequest.new
    fax_request.client_receipt_date = Time.now
    fax_request.recipient_number = recipient_number
    fax_request.recipient_name = recipient_name
    fax_request.file_path = file_path
    fax_request.save!
    tid = nil

    conn = Faraday.new(:url => FAX_SERVER_URL, :ssl => { :ca_file => 'C:/Ruby200/cacert.pem' }  ) do |faraday|
      faraday.request :multipart
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter Faraday.default_adapter
    end

    token = get_token()
    parts = ["sendfax?",
    "token=#{CGI.escape(token)}",
    "ApiKey=#{CGI.escape(APIKEY)}",
    "RecipientFax=#{recipient_number}",
    "RecipientName=#{recipient_name}",
    "OptionalParams=&"]
    path = "/api/" + parts.join("&")

    response = conn.post path do |req|
      req.body = {}
      req.body['file_name'] = Faraday::UploadIO.new("#{file_path}",file_specification(file_path)[0],file_specification(file_path)[1])
    end

    response_result = JSON.parse(response.body)
    fax_request.update_attributes(
                                  :status =>            response_result["isSuccess"],
                                  :message =>           response_result["message"],
                                  :SendFaxQueueId =>    response_result["SendFaxQueueId"],
                                  :send_confirm_date => response['date']
                                  )
    render json: fax_request
  end

  # Getting the File Name , the File Extension and validate the document type
  def file_specification(file_path)
    file_name = File.basename ("#{file_path}").downcase
    file_extension = File.extname (file_name).downcase

    if file_extension  == ".pdf"
      return "application/PDF",file_name

    elsif file_extension == ".txt"
     return "application/TXT",file_name

    elsif file_extension == ".doc"
      return "application/DOC",file_name

    elsif file_extension == ".docx"
      return "application/DOCX",file_name

    elsif file_extension == ".tif"
      return "application/TIF",file_name

    else
      return false
    end
  end

  # indexing the data
  def index
    @fax_requests = FaxRequest.all
      respond_to do |format|
        format.html
        format.csv { send_data @fax_requests.to_csv }
      end
  end

  private
    def set_fax_request
      @fax_request = FaxRequest.find(params[:id])
    end

  # The required parameters
    def fax_params
      params.require(:fax_request).permit(:recipient_name,:recipient_number,:file_path,:client_receipt_date,:status,:message,:send_confirm_date,:vendor_confirm_date)
    end
end
