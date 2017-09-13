class VendorStatus < ApplicationRecord

  after_create :send_status

  private

  def self.current_state
    last.service
  end

  def self.service_up?
    current_state == 'up'
  end

  def self.service_down?
    current_state == 'down'
  end

  def send_status
    WebServices::Web.client_fax_service_status(VendorStatus.current_state)
  end

end
