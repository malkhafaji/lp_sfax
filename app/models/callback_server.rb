class CallbackServer < ApplicationRecord
  validates_presence_of :url, :name, :insert_port
  validates_uniqueness_of :url
  has_many :fax_records
end
