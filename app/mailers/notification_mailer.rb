class NotificationMailer < ApplicationMailer
	def sys_error(e)
		 @message = e
	  mail(to: ENV['ADMIN_LIST'], subject:["[#{Rails.env}] Error on #{Rails.application.class.parent_name}"], body: @message )
	end
end
