class FaxResponse < ApplicationRecord
  belongs_to :fax_request
  has_one :fax_response

end
