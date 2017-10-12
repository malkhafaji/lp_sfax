include Sidekiq::Worker

class RefreshTokenJob
  sidekiq_options queue: 'refresh_token'
  def perform(user_id)
    user = User.find(user_id)
    unless user.refresh_token!
      raise user.errors.full_messages
    end
  end
end
