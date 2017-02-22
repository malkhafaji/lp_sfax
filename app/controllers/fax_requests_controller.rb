require './app/controllers/concerns/doxifer.rb'
require 'faraday'
require 'pp'
require 'time'
require 'json'

class FaxRequestsController < ApplicationController
  before_action :set_fax_request, only: [:show, :edit, :update, :destroy]

# The requirements to connect with Sfax
  USERNAME = "ealzubaidi"
  APIKEY = "817C7FD99D6146B89BEA88BA5B1E48DE"
  VECTOR = "x49e*wJVXr8BrALE"
  ENCRYPTIONKEY = "gZ!LaHKAmmuXd7AMamtPqIepQ7RMsbJ3"
  FAX_SERVER_URL = "https://api.sfaxme.com"


# The required parameters
  def fax_params
    params.require(:fax_request).permit(:recipient_name,:recipient_number,:file_path,:client_receipt_date,:status,:message,:send_confirm_date,:vendor_confirm_date)
  end
  #

# Create new,save and update fax request
  def create
    fax_request = FaxRequest.new(fax_params)
    fax_request.client_receipt_date = Time.now
    fax_request.save!
    response = send_fax(fax_params)
    update_fax_request(fax_request,response)
  end

# Getting TOKEN
    def get_token
      timestr = Time.now.utc.iso8601()
      raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
      dox = Doxipher.new(ENCRYPTIONKEY, {:base64=>true})
      cipher = dox.encrypt(raw)
      return cipher
    end

# Sending fax
  def send_fax (fax_params)
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
    "RecipientFax=#{fax_params["recipient_number"]}",
    "RecipientName=#{fax_params["recipient_name"]}",
    "OptionalParams=&"]
    path = "/api/" + parts.join("&")

    response = conn.post path do |req|
      req.body = {}
      req.body['file_name'] = Faraday::UploadIO.new( "#{fax_params["file_path"]}" , file_specification[0] , file_specification[1] )
    end

    return JSON.parse(response.body)
  end

# Getting the File Name , the File Extension and validate the document type
  def file_specification
    file_name = File.basename ("#{fax_params["file_path"]}").downcase
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

# Update Fax parameters with recipit parameters
  def update_fax_request(fax_request,response)
    fax_request.update_attributes(
                                  status: response["isSuccess"],
                                  message: response["message"],
                                  SendFaxQueueId: response["SendFaxQueueId"]
                                  )
  end


  def new
    @fax_request = FaxRequest.new
  end

  def index
    @fax_requests = FaxRequest.all
     end

    #@transactions = Transaction.where(account_id: params[:account_id])
 
   
   
     
 




  def show
  end

  def edit
  end

  def update
    respond_to do |format|
      if @fax_request.update(fax_request_params)
        format.html { redirect_to @fax_request, notice: 'Fax request was successfully updated.' }
        format.json { render :show, status: :ok, location: @fax_request }
      else
        format.html { render :edit }
        format.json { render json: @fax_request.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @fax_request.destroy
    respond_to do |format|
      format.html { redirect_to fax_requests_url, notice: 'Fax request was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_fax_request
      @fax_request = FaxRequest.find(params[:id])
    end

end
