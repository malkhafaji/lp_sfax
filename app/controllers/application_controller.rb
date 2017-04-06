class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  def run_tasks
    system "rake check_fax_response"
    system "rake sendback_final_response_to_client"
    redirect_to root_path
  end
end
