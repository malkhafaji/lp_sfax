include Sidekiq::Worker

class NotificationMailerJob
  sidekiq_options queue: 'notification_mailer'

  def perform(message)
    NotificationMailer.app_error(message).deliver
  end
end
