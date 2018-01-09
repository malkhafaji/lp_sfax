class FaxRecord < ApplicationRecord
  has_many :attachments,  dependent: :destroy
  has_one :callback_param,  dependent: :destroy
  belongs_to :callback_server
  after_validation :generate_fax_id,  on: :create

  validates_format_of :recipient_number, with: /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/
  validates_presence_of :recipient_name, :created_by, :recipient_number, :client_id

  scope :desc,-> {order('fax_records.updated_at DESC')}
  scope :without_queue_id, -> { where(send_fax_queue_id: nil).where(result_code: nil) }
  scope :without_response_q_ids, -> { where.not(send_fax_queue_id: nil).where(result_code: nil).where("max_fax_response_check_tries <= #{ENV['MAX_RESPONSE_CHECK'].to_i}").pluck(:send_fax_queue_id) }
  scope :not_send_to_client, -> { where(sendback_final_response_to_client: 0).where.not(send_fax_queue_id: nil, result_code: nil, callback_server_id: nil).group_by(&:callback_server_id) }

  def in_any_queue?
    retry_jobs = Sidekiq::RetrySet.new
    retry_jobs.each do |job|
      return true if job.args[0] == self.id
    end
    scheduled_jobs = Sidekiq::ScheduledSet.new
    scheduled_jobs.each do |job|
      return true if job.args[0] == self.id
    end
    return false
  end

  def self.by_month(desired_month)
    current_year = Time.now.year
    self.where("EXTRACT(YEAR FROM created_at) = ? AND EXTRACT(MONTH FROM created_at) = ?", current_year, desired_month)
  end

  def number_to_fax
    fax_number = recipient_number
    fax_number.insert(1,'-').insert(5,'-').insert(9,'-')
  end

  def self.filtered_fax_records(search_value)
    if(search_value.present?)
      FaxRecord.where(["recipient_name LIKE ? or recipient_number LIKE ?",
      ("%#{search_value}%"),("%#{search_value}%")])
    else
      FaxRecord.all
    end
  end
  
  def generate_fax_id
    self.fax_id = "#{SecureRandom.uuid}"
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
end
