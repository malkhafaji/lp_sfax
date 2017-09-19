class FaxRecordsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:homepage]
  def  homepage
  end

  # Exporting either all fax records OR the records results from filter (filtered_fax_records)
  def export
    if (session[:search_value].nil?)
      fax_records = FaxRecord.all
    else
      fax_records = FaxRecord.filtered_fax_records(session[:search_value])
    end
    respond_to do |format|
      format.csv do
        filename = "fax_records_csv_#{Date.today.strftime('%m_%d_%Y')}.csv"
        set_csv_streaming_headers(filename)
        self.response_body = fax_records.to_csv
      end
      format.xls do
        filename = "fax_records_xls_#{Date.today.strftime('%m_%d_%Y')}.xls"
        set_csv_streaming_headers(filename)
        self.response_body = fax_records.to_csv(col_sep: "\t")
      end

    end
  end

  # Render Index page with all fax records OR the records results from filter (filtered_fax_records) with pagenation
  def index
    @zone = ActiveSupport::TimeZone.new("Central Time (US & Canada)")
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
        @fax_records = FaxRecord.desc
      else
        @fax_records = filter_fax_records
      end
    end

    @per_page = ENV['pagination_per_page'].to_i
    @current_page = (params[:page].present? ? params[:page] : '1').to_i
    @total_record, @fax_records, @total_pages = FaxRecord.paginated_fax_record(page: @current_page, per_page:  @per_page, fax_list: @fax_records)
    respond_to do |format|
      format.html
    end
  end
  def report
     @desierd_month = params[:desierd_month] ||= Date.today.strftime("%m")
     @fax_records = FaxRecord.by_month(@desierd_month)

    respond_to do |format|
      format.html
    end
  end
  def url_report
    @fax_records_urls = FaxRecord.where(callback_url: params[:callback_url])
  end
  # private
  # # Use callbacks to share common setup or constraints between actions.
  # def set_fax_record
  #   @fax_record = FaxRecord.find(params[:id])
  # end
  #
  # # Never trust parameters from the scary internet, only allow the white list through.
  # def fax_record_params
  #   params.require(:fax_record).permit(:recipient_name, :recipient_number, :file_path, :client_receipt_date, :status, :SendFaxQueueId, :message, :max_fax_response_check_tries, :send_confirm_date, :vendor_confirm_date, :send_fax_queue_id, :is_success, :result_code, :error_code, :result_message, :recipient_fax, :tracking_code, :fax_date_utc, :fax_id, :pages, :attempts, :sender_fax, :barcode_items, :fax_success, :out_bound_fax_id, :fax_pages, :fax_date_iso, :watermark_id, :message)
  # end
end
