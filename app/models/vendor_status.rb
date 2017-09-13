class VendorStatus < ApplicationRecord

  after_create :send_status

  private

  def self.current_status
    last.service
  end

  def self.service_up?
    current_status == 'up'
  end

  def self.service_down?
    current_status == 'down'
  end

  def send_status
    WebServices::Web.client_fax_service_status(VendorStatus.current_status)
  end

end
