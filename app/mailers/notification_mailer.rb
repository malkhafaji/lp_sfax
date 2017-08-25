class NotificationMailer < ApplicationMailer
	def app_error(e)
		@message = e
	  mail(to: ENV['GMAIL_ADMIN'], subject: "[#{Rails.env.upcase}] Error on #{Rails.application.class.parent_name}", body: @message)
	end
end
