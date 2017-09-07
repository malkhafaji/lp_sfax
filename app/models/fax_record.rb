class FaxRecord < ApplicationRecord
  has_many :attachments
  validates_format_of :recipient_number, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/
  validates_presence_of :recipient_name, :callback_url
  scope :desc,-> {order('fax_records.updated_at DESC')}
  scope :without_queue_id, -> { where(send_fax_queue_id: nil) }
  scope :without_response_q_ids, -> { where.not(send_fax_queue_id: nil).where(result_code: nil).where("max_fax_response_check_tries <= #{ENV['MAX_RESPONSE_CHECK'].to_i}").pluck(:send_fax_queue_id) }
  # scope :posted_today, -> { posted_between_period(Time.now.midnight, Time.now.end_of_day) }

  def self.by_month(desired_month)
      self.where("cast(strftime('%m', created_at) as int) = ?", desired_month)
  end
  def number_to_fax
    fax_number = recipient_number
    fax_number.insert(1,'-').insert(5,'-').insert(9,'-')
  end

  def self.filtered_fax_records(search_value)
    FaxRecord.where(["recipient_name LIKE ? or recipient_number LIKE ?",
    (search_value),(search_value)])
  end

  # Generating CSV file either for all records OR the records results from filter
  def self.to_csv(options = {})
    columns_headers = {id:'Fax ID',recipient_name:'Recipient name',recipient_number:'Recipient number',file_path:'File(s) name',message:'Confirmation Message',result_message:'Status',attempts:'Attempts',pages:'Pages',sender_fax:'Sender No.',created_at:'Request Initiated',client_receipt_date:'Request Sent to Vendor',send_confirm_date:'Vendor Confirmation',fax_duration:'Duration'}
    attributes = %w{id recipient_name recipient_number file_path message result_message attempts pages sender_fax created_at client_receipt_date send_confirm_date fax_duration}
    CSV.generate(options) do |csv|
      csv << columns_headers.values
      current_scope.each do |fax_record|
        csv << attributes.map{ |attr| fax_record.send(attr) }
      end
    end
  end




  # Paginate through pages and displaying next and back buttons
  def self.paginated_fax_record(params)
    fax_list = params[:fax_list]
    per_page  = params[:per_page].to_i
    page   = params[:page].to_i
    total_pages = fax_list.size/per_page + (fax_list.size % per_page > 0 ? 1 :0)

    if (params[:page].to_i < 1) || (params[:page].to_i > total_pages)
      return [0, {},0]
    else
      offset  = per_page * (page - 1)
      fax_record_batch = fax_list.offset(offset).limit(per_page) unless offset > fax_list.size
      return [fax_list.size, fax_record_batch, total_pages]
    end
  end
end
