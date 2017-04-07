require 'rails_helper'
RSpec.describe FaxRecordsController  do


# before(:all) do
#  @fax_record_1 = FaxRecord.create(recipient_name: "recipient_name_1", recipient_number: "recipient_number_1", file_path: "file_path_1")
# end

	let (:fax_records) {FaxRecord.all}
	describe 'Get index' do 
it "assigns all fax_records to @fax_records" do 

	get :index
	expect(assigns be_valid ['fax_records']) ==(fax_records)
     end 
   end

  describe 'GET #index' do
   it 'responds successfully with an HTTP 200 status code' do
     get :index
     assert_response :success
     expect(response).to have_http_status(200)
     expect(subject).to render_template(:index)
   end
 end
  
	describe  "#export" do
		it "should export fax_record" do
			expect(response.content_type) ==('application/csv') 
		end
		it "should export fax_record" do
			expect(response.content_type) ==('application/xls')
		end
	end




end 