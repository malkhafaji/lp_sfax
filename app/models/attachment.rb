class Attachment < ApplicationRecord
  belongs_to :fax_record
  validates_presence_of :file_key
end
