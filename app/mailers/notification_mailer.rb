class NotificationMailer < ApplicationMailer
	def sys_error(e)
		 @message = e
	  mail(to:  ENV['GMAIL_ADMIN'], subject:["[#{Rails.env}]""  ""Error on ""#{Rails.application.class.parent_name}"], body: @message )
	end
end
