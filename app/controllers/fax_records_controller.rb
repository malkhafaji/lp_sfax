class FaxRecordsController < ApplicationController
  require './lib/fax_common_methodes/module.rb'
  skip_before_filter  :verify_authenticity_token
  before_action :set_fax_record, only: [:show, :edit, :update, :destroy]

  # Taking the fax_number,recipient_name and the attached file path and call the actual sending method to send the fax (made by the client)
  def send_fax
    recipient_name = params['recipient_name']
    recipient_number = params['recipient_number']


    file_path = file_path("test22.txt") # hardcoded

    fax_record =FaxRecord.new
    fax_record.client_receipt_date = Time.now
    fax_record.recipient_number = recipient_number
    fax_record.recipient_name = recipient_name
    fax_record.file_path = file_path
    fax_record.save!
    actual_sending(recipient_name,recipient_number,file_path,fax_record.id, fax_record.update_attributes(updated_by_initializer: false))
  end

  # Exporting either all fax records OR the records results from filter (filtered_fax_records)
  def export
    if (session[:search_value].nil?)
      fax_records = FaxRecord.all
    else
      fax_records = FaxRecord.filtered_fax_records(session[:search_value])
    end
    respond_to do |format|
      format.html
      format.csv { send_data fax_records.to_csv}
      format.xls { send_data fax_records.to_csv(col_sep: "\t") }
    end
  end

  # Render Index page with all fax records OR the records results from filter (filtered_fax_records) with pagenation
  def index
    @search_value = params[:search_value]
    filter_fax_records = FaxRecord.filtered_fax_records(@search_value)
    session[:search_value] = @search_value

    if @search_value && @search_value.empty?
      flash.now.alert = "Search value should not be empty !"
      @fax_records = FaxRecord.all
    elsif  !@search_value.blank? && !filter_fax_records.present?
      flash.now.alert = "No results matching the search value (#{@search_value})"
      @fax_records = FaxRecord.all
    else
      if !filter_fax_records.present?
        @fax_records = FaxRecord.all
      else
        @fax_records = filter_fax_records
      end
    end

    @per_page = 10
    @current_page = (params[:page].present? ? params[:page] : '1').to_i
    @total_record, @fax_records, @total_pages = FaxRecord.paginated_fax_record(page: @current_page, per_page:  @per_page, fax_list: @fax_records)
    respond_to do |format|
      format.html
    end
  end

# calling the file from the public folder /send_document
  def file_path(file_name)
    return  "#{Rails.root}/public/send_document/#{file_name}"
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
