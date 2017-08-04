class NotificationMailer < ApplicationMailer
	def sys_error(e)
		 @message = e
	  mail(to:  ENV['gmail_admin'], subject:["#{Rails.env}","Error on ","#{File.basename(Rails.root.to_s)}"], body: @message )

		puts ENV['gmail_admin']
	end
end
