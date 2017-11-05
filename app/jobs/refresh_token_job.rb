class RefreshTokenJob < ActiveJob::Base
  def perform(user_id)
    user = User.find(user_id)
    unless user.refresh_token!
      raise user.errors.full_messages
    end
  end
end
