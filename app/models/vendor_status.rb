class VendorStatus < ApplicationRecord

  after_create :send_status

private

  def self.last_state
    last.service
  end

  def send_status
    WebServices::Web.client_fax_service_status(VendorStatus.last_state)
  end

end
