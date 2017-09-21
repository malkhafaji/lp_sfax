module FaxRecordsHelper
  def active_class(callback_url, site)
      'btn-info' if callback_url == site
  end
end
