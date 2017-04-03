class FaxRecord < ApplicationRecord

  validates_format_of :recipient_number, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/
  validates_presence_of :recipient_name, message: "Recipitent Name should not be empty"
  

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
    attributes = %w{recipient_name recipient_number file_path status message result_message sender_fax pages attempts
      client_receipt_date send_confirm_date vendor_confirm_date}
    CSV.generate(options) do |csv|
      csv << attributes
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
