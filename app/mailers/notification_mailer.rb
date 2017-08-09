class NotificationMailer < ApplicationMailer
	def sys_error(e, methodname)
		 @message = e
		 @methodname = methodname
	  mail(to: ENV['GMAIL_ADMIN'], subject: "[#{Rails.env.upcase}] Error on #{Rails.application.class.parent_name}", body: "[#{@message}] [#{@methodname}]")
	end
end
