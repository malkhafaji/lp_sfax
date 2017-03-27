require 'rails_helper'

RSpec.describe FaxRecordsController, type: :controller do
	describe "GET #index" do
		it "returns a 200 OK status" do
			get :index
			expect(response).to have_http_status(:ok)
		end
	end
	describe  "#export" do
		it "should export fax_record" do
			expect(response.content_type) ==('application/csv') 
		end
		it "should export fax_record" do
			expect(response.content_type) ==(session[:search_value])
		end
	end
end
