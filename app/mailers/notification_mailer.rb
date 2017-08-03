class NotificationMailer < ApplicationMailer
	def sys_error(e)
		 @message = e
	  mail(to: "louy@gilgabytes.com", subject: "Exception Accrue Need your Attention", body: @message )
    end
end
