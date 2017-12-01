class User < ApplicationRecord
  require 'open-uri'
  require 'net/http'
  devise :database_authenticatable, :timeoutable
  devise :omniauthable, omniauth_providers: [:azure_oauth2]

  def self.from_omniauth(auth)
    user = find_by_email(auth.info.email)
    if user
        user.update(timeout: (auth.credentials.expires_at - Time.now.to_i)/60)
    else
      user = self.new
      user.email = auth.info.email
      user.name = auth.info.name
      user.timeout = (auth.credentials.expires_at - Time.now.to_i)/60
      user.save!
    end
    user
  end

  def timeout_in
    timeout.minutes
  end
end
