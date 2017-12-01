class FaxRecordDatatable
  delegate :params, :link_to, to: :@view
  def initialize(view)
    @view = view
  end
  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: FaxRecord.count,
      iTotalDisplayRecords: fax_records.total_entries,
      aaData: data
    }
  end
  private
    def data
      @zone = ActiveSupport::TimeZone.new("Central Time (US & Canada)")
      fax_records.map do |fax_record|
        [
          link_to(fax_record.id, fax_record),
          link_to(fax_record.recipient_name, fax_record),
          helper.number_to_phone(fax_record.recipient_number, area_code: true),
          fax_record.message,
          fax_record.result_message,
          fax_record.attempts,
          fax_record.pages,
          fax_record.created_at.in_time_zone(@zone).strftime("%m/%d/%Y %I:%m:%S %p")
        ]
     end
    end

    def fax_records
      @fax_records ||= fetch_fax_records
    end

  def fetch_fax_records
    if params[:id]
      fax_records = FaxRecord.where(id: params[:id].to_i)
    else
      fax_records = FaxRecord.order("#{sort_column} #{sort_direction}")
    end
    fax_records = fax_records.page(page).per_page(per_page)
    if params[:search][:value].present?
      fax_records = fax_records.where("id::text like :search or lower(recipient_name) like :search  or recipient_number like :search or lower(result_message) like :search", search: "%#{params[:search][:value].downcase}%")
    end
    fax_records
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

 def sort_column
    columns = %w[id recipient_name recipient_number result_message]
    columns[params[:order]['0'][:column].to_i]
  end

  def sort_direction
    params[:order]['0'][:dir] == 'desc' ? 'desc' : 'asc'
  end

  def helper
    @helper ||= Class.new do
      include ActionView::Helpers::NumberHelper
    end.new
  end
end
