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
end
