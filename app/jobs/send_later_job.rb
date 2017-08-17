class SendLaterJob < ApplicationJob
  queue_as :default

  def perform(e)
    @message = e
    NotificationMailer.app_error(@message).deliver_later
  end
end
