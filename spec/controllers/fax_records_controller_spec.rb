require 'rails_helper'

RSpec.describe FaxRecordsController, type: :controller do
	describe "GET #index" do
    it "returns a 200 OK status" do
      get :index
      expect(response).to have_http_status(:ok)
    end
end

#describe "GET #export" do
    #it "returns a 200 OK status" do
     # get :export
     # expect(response).to have_http_status(:ok)
    #end
#end



     describe  "#export" do
  
   	it "should export fax_record" do
     expect(response.content_type) ==('application/csv') 
   end
   it "should export fax_record" do
   	expect(response.content_type) ==(session[:search_value])
   end
    end

   

end







# def export
    #if (session[:search_value].nil?)
     # fax_records = FaxRecord.all
   # else
    #  fax_records = FaxRecord.filtered_fax_records(session[:search_value])
   # end
    #respond_to do |format|
     # format.html
    # end


    
       
  # private
 #       # Proxy to to_param if the object will respond to it.
  #      def parameterize(value)
   #       value.respond_to?(:to_param) ? value.to_param : value
    #    end

     #   def normalize_argument_to_redirection(fragment)
      #    if Regexp === fragment
       #     fragment
        #  else
         #   handle = @controller || ActionController::Redirecting
          #  handle._compute_redirect_to_location(@request, fragment)
          #end
       # end






