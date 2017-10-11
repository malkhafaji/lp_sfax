class FaxRecordsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:homepage]
  def  homepage
  end

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

  def index
    session[:search_value] = (params["search"]["value"] rescue nil)
    respond_to do |format|
      format.html
      format.json { render json: FaxRecordDatatable.new(view_context) }
    end

    @zone = ActiveSupport::TimeZone.new("Central Time (US & Canada)")
    @search_value = params[:search_value]
    filter_fax_records = FaxRecord.filtered_fax_records(@search_value)
    #session[:search_value] = @search_value

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
  end

  def report
    @desierd_month = params[:desierd_month] ||= Date.today.strftime('%m')
    @fax_records = FaxRecord.by_month(@desierd_month).where.not(send_fax_queue_id: nil)
    @month_name = Date::MONTHNAMES[@desierd_month.to_i]
    @types_hash = Hash.new(0)
    failed_faxes = @fax_records.where.not(result_message: 'Success')
    failed_faxes.each do |fax_record|
      message_type = fax_record.result_message
      @types_hash[message_type] += 1 unless  message_type == nil
    end
    total_sccess = @fax_records.where(is_success: 't')
    @success = total_sccess.present? ? ((total_sccess.size.to_f / @fax_records.size) * 100).to_i : 0
    @chart_display = {}
    records = @fax_records.group(:is_success).count
    records.each do |key, value|
      key == 't' ? @chart_display['Success'] = records[key] :  @chart_display['Fail'] = records[key]
    end
  end

  def environment_report
    @urls = CallbackServer.all.includes(:fax_records)
    callback = params[:callback_server] ? params[:callback_server] : @urls.first.id
    callback_server = @urls.find(callback)
    @fax_records = callback_server.fax_records
  end

  def issues
    @unsent_fax_records =  FaxRecord.where(sendback_final_response_to_client: 0)
  end
end
