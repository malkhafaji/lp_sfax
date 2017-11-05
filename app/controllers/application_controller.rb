class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate_user!

  def run_tasks
    system "rake check_fax_response"
    system "rake sendback_final_response_to_client"
    redirect_to root_path
  end

  def set_csv_streaming_headers(filename)
    response.headers['Content-Type']              = 'text/csv'
    response.headers['Content-Disposition']       = "attachment; filename=\"#{filename}\""
    response.headers['Content-Transfer-Encoding'] = 'binary'
    response.headers['Last-Modified']             = Time.now.ctime.to_s
  end




  private

  def authenticate_user!
    if current_user
      if current_user.token_expired?
        redirect_to signout_path(user_id: current_user.id)
      else
        RefreshTokenJob.perform_later(current_user.id)
      end
    else
      redirect_to root_url
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end

  helper_method :current_user
end
