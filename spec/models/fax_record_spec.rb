require 'rails_helper'

RSpec.describe FaxRecord, type: :model do

	before(:all) do
	@fax_record = FaxRecord.new(recipient_name: "gilgabytes", recipient_number: "12345678912", file_path: "gilga.txt", status: "Red", barcode_items: "BARCODE", result_message: "GREEN", message: "Received", attempts:  0 , pages: 0, sender_fax: "888-888-8888", recipient_fax: "777-777-7777", max_fax_response_check_tries: 3,  )
	end
	it "should have a recipient_name "do
	expect(@fax_record.recipient_name).to eq("gilgabytes")
	end
	it "should have a recipient_number"do
	expect( @fax_record.recipient_number).to eq("12345678912")
	end
	it "should have a file_path "do
	expect( @fax_record.file_path).to eq("gilga.txt")
	end
	it "should have a status "do
	expect(  @fax_record.status ).to eq("Red")
	end
	it "should have a barcode_items "do
	expect( @fax_record.barcode_items ).to eq("BARCODE")
	end
	it "should have a result_message"do
	expect( @fax_record.result_message ).to eq("GREEN")
	end
	it "should have a message"do
	expect( @fax_record.message).to eq("Received")
	end
	it "should have a attempts"do
	expect( @fax_record.attempts).to eq(0)
	end
	it "should have a pages"do
	expect( @fax_record.pages ).to eq(0)
	end
	it "should have a sender_fax"do
	expect( @fax_record.sender_fax).to eq("888-888-8888")
	end
	it "should have a recipient_fax"do
	expect( @fax_record.recipient_fax).to eq("777-777-7777")
    end
    #it "should have a client_receipt_Time.now"do
	#expect( @fax_record.client_receipt_Time.now).to eq(DateTime.now.to s)
    #end
    #it "should have a vendor_confirm_Time.now"do
	#expect( @fax_record.vendor_confirm_Time.now).to eq(DateTime.now.to s)
    #end
    it "should have a max_fax_response_check_tries "do
	expect( @fax_record.max_fax_response_check_tries).to eq(3)
    end
    #it "should have a send_confirm_Time.now "do
	#expect( @fax_record.send_confirm_Time.now).to eq(DateTime.now.to s)
    #end


	
end



