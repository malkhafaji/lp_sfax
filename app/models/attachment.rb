class Attachment < ApplicationRecord
  belongs_to :fax_record
  validates_presence_of :fax_record_id, :file_unique_key
end
