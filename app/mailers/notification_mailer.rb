class NotificationMailer < ApplicationMailer
	def sys_error(e)
		 @message = e
	  mail(to:  ENV['GMAIL_ADMIN'], subject:["#{Rails.env}""  ""Error on ""#{File.basename(Rails.root.to_s)}"], body: @message )
	end
end
