class User < ApplicationRecord
  require 'open-uri'
  require 'net/http'

  def self.from_omniauth(auth)
    user = find_by_email(auth.info.email)
    if user
      user.update_attributes(refresh_token: auth.credentials.refresh_token,
        access_token: auth.credentials.token, access_token_expires_at: Time.at(auth.credentials.expires_at),
        last_sign_in_at: Time.now)
    else
      user = self.new
      user.email = auth.info.email
      user.name = auth.info.name
      user.last_sign_in_at = Time.now
      user.refresh_token = auth.credentials.refresh_token
      user.access_token = auth.credentials.token
      user.access_token_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
    user
  end

  def to_params
    {'refresh_token' => refresh_token,
    'client_id' => ENV['CLIENT_ID'],
    'client_secret' => ENV['CLIENT_SECRET'],
    'grant_type' => 'refresh_token'}
  end

  def request_token_from_azure
    url = URI("https://login.microsoftonline.com/common/oauth2/token")
    Net::HTTP.post_form(url, self.to_params)
  end

  def refresh_token!
    response = request_token_from_azure
    data = JSON.parse(response.body)
    update_attributes(
    access_token: data['access_token'],
    access_token_expires_at: Time.now + (data['expires_in'].to_i).seconds)
  end

  def token_expired?
    Time.at(access_token_expires_at) < Time.now
  end
end
