module FaxRecordsHelper
	def active_class(callback_server_id, url)
     'btn-info' if callback_server_id ==  url.id.to_s
    end
end
