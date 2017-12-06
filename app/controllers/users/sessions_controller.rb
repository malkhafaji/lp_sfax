class Users::SessionsController < Devise::SessionsController
  # DELETE /resource/sign_out
   def destroy
     signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
     set_flash_message! :notice, :signed_out if signed_out
     yield if block_given?
     redirect_to "https://login.microsoftonline.com/common/oauth2/logout?post_logout_redirect_uri=#{root_url}"
   end
end
