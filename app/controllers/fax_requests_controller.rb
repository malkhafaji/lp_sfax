require './app/controllers/concerns/doxifer.rb'

class FaxRequestsController < ApplicationController
  before_action :set_fax_request, only: [:show, :edit, :update, :destroy]

  USERNAME = "ealzubaidi"
  APIKEY = "817C7FD99D6146B89BEA88BA5B1E48DE"
  VECTOR = "x49e*wJVXr8BrALE"
  ENCRYPTIONKEY = "gZ!LaHKAmmuXd7AMamtPqIepQ7RMsbJ3"
  FAX_SERVER_URL = "https://api.sfaxme.com"
  require 'faraday'
  require 'pp'
  require 'time'
  require 'json'



# Inserting the parameters
  def fax_params
    params.require(:fax_request).permit(:recipient_name,:recipient_number,:file_path,:client_receipt_date,:status,:message,:send_confirm_date,:vendor_confirm_date)
  end



#1. validate in the model

#2. create fax_request
  def create
    fax_request = FaxRequest.new(fax_params)
    fax_request.send_confirm_date = Time.now
    fax_request.save!
    response = send_fax(fax_params)
    update_fax_request(fax_request,response)

    # fax_params["vendor_confirm_date"] = hash[""],
    # if (!fax_request.save)
    #  return json: fax_request.errors and return
    # end
  end

#3. sending fax
  #3-1 Getting TOKEN
    def get_token
      timestr = Time.now.utc.iso8601()
      raw = "Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}"
      dox = Doxipher.new(ENCRYPTIONKEY, {:base64=>true})
      cipher = dox.encrypt(raw)
      return cipher
    end

#3-2 sending fax
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
      req.body['file_name'] = Faraday::UploadIO.new( "#{fax_params["file_path"]}" , file_specification[0] , file_specification[1])
    end
    return JSON.parse(response.body)
  end

  def file_specification
    file_name = File.basename ("#{fax_params["file_path"]}").downcase    # this is hardcode path We need to change the path to  ("#{fax_params['file_path']}")
    file_extension = File.extname (file_name).downcase




    if file_extension  == ".pdf"
      return ["application/PDF",file_name]
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




#4. update fax_request: "Fri, 17 Feb 2017 16:41:30 GMT"

  def update_fax_request(fax_request,response)

    fax_request.update_attributes(
                                  status: response["isSuccess"],
                                  message: response["message"],
                                  SendFaxQueueId: response["SendFaxQueueId"]
                                  )

    # fax_request.update_all(, fax_vendor_confirm_date: response[body][fax_vender_confirm_date])
    # pp response.body
    # pp fax_request
  end

#5. create response_json
  def create_response_json(fax_params)
   hash = {recipient_number: fax_request.recipient_number, file_path: fax_request.file_path, recipient_name: fax_request.recipient_name}
   return hash
  end

#6. return 5
  def return5
    render json: response_json
  end

















  def index
    @fax_requests = FaxRequest.all
  end

  def show


  end

  def new
    @fax_request = FaxRequest.new
  end

  def edit
  end

  # def create
  #   @fax_request = FaxRequest.new(fax_params)
  #
  #   respond_to do |format|
  #     if @fax_request.save
  #       format.html { redirect_to @fax_request, notice: 'Fax request was successfully created.' }
  #       format.json { render :show, status: :created, location: @fax_request }
  #     else
  #       format.html { render :new }
  #       format.json { render json: @fax_request.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

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
