class SessionsController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    user = User.from_omniauth(env["omniauth.auth"])
    session[:user_id] = user.id
    redirect_to fax_records_url
  end

  def logout
    user = User.find(params[:user_id])
    user.update_attributes(refresh_token: nil, access_token: nil, access_token_expires_at: nil)
    reset_session
    redirect_to "https://login.microsoftonline.com/common/oauth2/logout?post_logout_redirect_uri=#{root_url}"
  end
end
