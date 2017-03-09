class FaxRecordsController < ApplicationController
  skip_before_filter  :verify_authenticity_token
  before_action :set_fax_record, only: [:show, :edit, :update, :destroy]
  require './app/controllers/concerns/doxifer.rb'
  require 'faraday'
  require 'pp'
  require 'time'
  require 'json'

# The requirements to connect with Vendor
  USERNAME = 'ealzubaidi'
  APIKEY = '817C7FD99D6146B89BEA88BA5B1E48DE'
  VECTOR = 'x49e*wJVXr8BrALE'
  ENCRYPTIONKEY = 'gZ!LaHKAmmuXd7AMamtPqIepQ7RMsbJ3'
  FAX_SERVER_URL = 'https://api.sfaxme.com'

# Getting TOKEN
  def get_token
    timestr = Time.now.utc.iso8601()
    raw = 'Username=#{USERNAME}&ApiKey=#{APIKEY}&GenDT=#{timestr}'
    dox = Doxipher.new(ENCRYPTIONKEY, {base64: true})
    cipher = dox.encrypt(raw)
    return cipher
  end

# Sending fax Fax Request
  def send_fax
    recipient_number = params['recipient_number']
    file_path = params['file_path']
    recipient_name = params['recipient_name']
    fax_record =FaxRecord.new
    fax_record.client_receipt_date = Time.now
    fax_record.recipient_number = recipient_number
    fax_record.recipient_name = recipient_name
    fax_record.file_path = file_path
    fax_record.save!
    tid = nil
    conn = Faraday.new(url: FAX_SERVER_URL, ssl: { ca_file: 'C:/Ruby200/cacert.pem' }  ) do |faraday|
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
      req.body['file_name'] = Faraday::UploadIO.new("#{file_path}", file_specification(file_path)[0], file_specification(file_path)[1])
    end
    response_result = JSON.parse(response.body)
    fax_record.update_attributes(
      status:            response_result["isSuccess"],
      message:           response_result["message"],
      SendFaxQueueId:    response_result["SendFaxQueueId"],
      send_confirm_date: response['date'])
    render json: fax_record
  end

# Getting the File Name , the File Extension and validate the document type
  def file_specification(file_path)
    file_name = File.basename ("#{file_path}").downcase
    file_extension = File.extname (file_name).downcase
    if file_extension  == ".pdf"
      return "application/PDF", file_name
    elsif file_extension == ".txt"
      return "application/TXT", file_name
    elsif file_extension == ".doc"
      return "application/DOC", file_name
    elsif file_extension == ".docx"
      return "application/DOCX", file_name
    elsif file_extension == ".tif"
      return "application/TIF", file_name
    else
      return false
    end
  end


# Render the index page with all the records OR Render the records that specified in the search criteria
  def index

    if request.post?
      search_value = params[:search_value]
      filter_result = FaxRecord.filtered_fax_records(search_value)
      if search_value.nil? || search_value.empty?
        flash.now.alert = "Search value should not be empty !"
        @fax_records = FaxRecord.all
        render :index
      elsif  !filter_result.present? || filter_result.empty?
        flash.now.alert = "No results matching the search value ( #{search_value} )"
        @fax_records = FaxRecord.all
        render :index
      elsif !search_value.nil? && !search_value.empty? && !filter_result.nil? && !filter_result.empty?
        @fax_records = filter_result
        session[:fax_records_ids] = @fax_records.pluck(:id)
        flash.now.notice = "Results matching the value ( #{search_value} )"
        respond_to do |format|
          format.html
          format.csv { send_data @fax_records.to_csv }
          format.xls { send_data @fax_records.to_csv(col_sep: "\t") }
        end
      end
    else

      @per_page = 5
      @current_page = (params[:page].present? ? params[:page] : '1').to_i
      @total_record, @fax_records, @total_pages = FaxRecord.paginated_fax_record(page: @current_page, per_page:  @per_page)


      @fax_records = FaxRecord.all
      render :index




    end
  end







  private

# Use callbacks to share common setup or constraints between actions.
  def set_fax_record
    @fax_record = FaxRecord.find(params[:id])
  end

# Never trust parameters from the scary internet, only allow the white list through.
  def fax_record_params
    params.require(:fax_record).permit(:recipient_name, :recipient_number, :file_path, :client_receipt_date, :status, :SendFaxQueueId, :message, :max_fax_response_check_tries, :send_confirm_date, :vendor_confirm_date, :send_fax_queue_id, :is_success, :result_code, :error_code, :result_message, :recipient_fax, :tracking_code, :fax_date_utc, :fax_id, :pages, :attempts, :sender_fax, :barcode_items, :fax_success, :out_bound_fax_id, :fax_pages, :fax_date_iso, :watermark_id, :message)
  end
end
