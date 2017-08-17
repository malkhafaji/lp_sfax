class SendLaterJob < ApplicationJob
  queue_as :default

  def perform(e)
    @message = e
    NotificationMailer.app_error(@message).deliver_now <<<<<<this class we user the actionmailerclass and the method then we pass in the contents
  end
end
