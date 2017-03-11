class FaxRecord < ApplicationRecord

  # Validate the recipient number to be only integers , 11 digit length and can not be empty
    validates   :recipient_number,numericality: {only_integer: true,message: "Recipient Number should not be Empty"},
      length: {minimum: 11,maximum: 11,message: "Recipient Number should be 11 digit"},allow_blank: false

  # Validate the recipient name to not be empty
    validates_presence_of :recipient_name,message: "Recipitent Name should not be empty"

  # Validate the Uploaded file to not be empty
    validates_presence_of :file_path, message: "Attached file should not be empty"

  # Filtering the fax records according to the entered search value
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
