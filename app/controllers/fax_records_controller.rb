class FaxRecordsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:homepage]
  @zone = ActiveSupport::TimeZone.new("Central Time (US & Canada)")
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
    session[:search_value] = (params['search']['value'] rescue nil)
    respond_to do |format|
      format.html
      format.json { render json: FaxRecordDatatable.new(view_context) }
    end
  end

  def show
    @zone = ActiveSupport::TimeZone.new("Central Time (US & Canada)")
    @fax = FaxRecord.find(params[:id])
  end

  def reports
    if params[:type] == 'monthly'
      @desierd_month = params[:desierd_month] ||= Date.today.strftime('%m')
      @fax_records = FaxRecord.by_month(@desierd_month).where.not(send_fax_queue_id: nil)
      @month_name = Date::MONTHNAMES[@desierd_month.to_i]
    elsif params[:type] == 'environments'
      @environments = CallbackServer.all
      e = params[:environment] ? params[:environment] : @environments.first.id
      @environment = CallbackServer.find(e)
      @fax_records = FaxRecord.where(callback_server: @environment).where.not(send_fax_queue_id: nil)
    end
    @types_hash = Hash.new(0)
    failed_faxes = @fax_records.where.not(result_message: 'Success')
    failed_faxes.each do |fax_record|
      message_type = fax_record.result_message
      @types_hash[message_type] += 1 unless  message_type == nil
    end
    total_success = @fax_records.where(is_success: 't')
    @success = total_success.present? ? ((total_success.size.to_f / @fax_records.size) * 100).to_i : 0
    @chart_display = {}
    records = @fax_records.group(:is_success).count
    records.each do |key, value|
      key == 't' ? @chart_display['Success'] = records[key] :  @chart_display['Fail'] = records[key]
    end
  end

  def issues
    @unsent_fax_records =  FaxRecord.where(sendback_final_response_to_client: 0)
  end
end
