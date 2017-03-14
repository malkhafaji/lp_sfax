require 'rails_helper'

RSpec.describe FaxRecordsController, type: :controller do
	#let(:fax_records) {FaxRecord.all}

	#describe 'GET index' do
    #it "assigns all fax_records to @fax_records" do 
    #get:index
    #expect(assigns['fax_records']).to eq(fax_records)
    #end
	#end

    it "#index" do
        get :index
        expect(response).to have_http_status(200)
    end

#it "alloes fax_records file exteintions " do 
#fax_record = FaxRecord.new
#fax_record = 'lol.pdf'
 #expect (fax_record).to eq('lol.pdf')

#end


    #expect (@per_page = 10).to eq(10)

end
