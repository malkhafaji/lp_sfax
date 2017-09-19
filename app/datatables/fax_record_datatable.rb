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
      fax_records.map do |fax_record|
        [
          fax_record.id,
          fax_record.recipient_name,
          fax_record.number_to_fax,
          fax_record.message,
          fax_record.result_message,
          fax_record.attempts,
          fax_record.pages,
          fax_record.sender_fax,
          fax_record.created_at.in_time_zone(@zone).strftime("%m/%d/%Y %I:%m %p"),
          fax_record.client_receipt_date.in_time_zone(@zone).strftime("%m/%d/%Y %I:%m %p"),
          fax_record.send_confirm_date,
          fax_record.fax_duration
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
    if params[:search].present?
      fax_records = fax_records.where("fax_id like :search or recipient_name like :search or result_message like :search or recipient_number like :search", search: "%#{params[:search][:value]}%")
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
      columns = %w[id]
      columns[params[:iSortCol_0].to_i]
    end
    def sort_direction
      params[:sSortDir_0] == "desc" ? "desc" : "asc"
    end
end