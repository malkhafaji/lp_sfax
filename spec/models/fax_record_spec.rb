require 'rails_helper'

RSpec.describe FaxRecord, type: :model do

  list_of_all_methods_in_the_class = FaxRecord.methods.sort
  describe "names for methods for the application should be the same in the test" do

    it 'Search for Method with name filtered_fax_records' do
      expect(list_of_all_methods_in_the_class.grep(:filtered_fax_records)).to eq([:filtered_fax_records])
    end
    it 'Search for Method with name to_csv' do
      expect(list_of_all_methods_in_the_class.grep(:to_csv)).to eq([:to_csv])
    end
    it 'Search for Method with name paginated_fax_record' do
      expect(list_of_all_methods_in_the_class.grep(:paginated_fax_record)).to eq([:paginated_fax_record])
    end
  end

  describe '.filtered_fax_records' do
    it ' should return a value' do
      expect('search_value').to eq('search_value')
    end
  end

  describe '.to_csv'do
    describe 'csv file should have these attributes' do
      it 'should have a name in recipient_name' do
      fax_record_attributes=FaxRecord.new
      fax_record_attributes.recipient_name ='recipient_name'
      expect(fax_record_attributes.recipient_name).to eq('recipient_name')
    end
      it 'should have a number in recipient_number' do
      fax_record_attributes=FaxRecord.new
      fax_record_attributes.recipient_number ='recipient_number'
      expect(fax_record_attributes.recipient_number).to eq('recipient_number')
    end
      it 'should have a file path in file_path' do
      fax_record_attributes=FaxRecord.new
      fax_record_attributes.file_path ='file_path'
      expect(fax_record_attributes.file_path).to eq('file_path')
    end
      it 'should have a message in message' do
      fax_record_attributes=FaxRecord.new
      fax_record_attributes.message ='Fax is received and being processed'
      expect(fax_record_attributes.message).to eq('Fax is received and being processed')
    end
      it 'should have a result message in result_message' do
      fax_record_attributes=FaxRecord.new
      fax_record_attributes.result_message ='result_message'
      expect(fax_record_attributes.result_message).to eq('result_message')
    end
      it 'should have a status message in status' do
      fax_record_attributes=FaxRecord.new
      fax_record_attributes.status = 'status'
      expect(fax_record_attributes.status).to eq('status')
    end
  end
  end

  describe 'Model should have validations' do
    it "is valid with valid attributes" do
      expect(FaxRecord.new).not_to be_valid
    end
    it "is valid with valid attributes" do
      subject.recipient_name = "John"
      subject.recipient_number = "888-888-88888"
      expect(subject).to be_valid
    end
    it "is not valid without a recipient_name" do
     expect(subject).to_not be_valid
    end
    it "is not valid without a recipient_number" do
     expect(subject).to_not be_valid
    end
    it "is not valid without a recipient_number" do
      subject.recipient_name = "John"
      expect(subject).to_not be_valid
    end
    it "is not valid without a recipient_name" do
      subject.recipient_number = "888-888-88888"
      expect(subject).to_not be_valid
    end
    it "is not valid without a recipient_name" do
      subject.recipient_name = nil
      expect(subject).to_not be_valid
    end
    it "is not valid without a recipient_number" do
      subject.recipient_number = nil
      expect(subject).to_not be_valid
    end
  before(:all) do
    @fax_record = FaxRecord.new(recipient_name: "John", recipient_number: "12345678912", file_path: "gilga.txt",
    status: "Red",  result_message: "GREEN", message: "Received", attempts:  0 , pages: 1, sender_fax: "888-888-8888",
    recipient_fax: "777-777-7777", fax_id: 10, fax_success: 1, updated_by_initializer: true,
    send_fax_queue_id:"123456789", SendFaxQueueId: "123456789123456789")
    end
      it "should have a recipient_name "do
      expect(@fax_record.recipient_name).to eq("John")
      end
      it "should have a recipient_number "do
      expect(@fax_record.recipient_number).to eq("12345678912")
      end
      it "should have a file_path "do
      expect(@fax_record.file_path).to eq("gilga.txt")
      end
      it "should have a status "do
      expect(@fax_record.status).to eq("Red")
      end
      it "should have a result_message "do
      expect(@fax_record.result_message).to eq("GREEN")
      end
      it "should have a message "do
      expect(@fax_record.message).to eq("Received")
      end
      it "should have a attempts "do
      expect(@fax_record.attempts).to eq(0)
      end
      it "should have a pages "do
      expect(@fax_record.pages).to eq(1)
      end
      it "should have a sender_fax "do
      expect(@fax_record.sender_fax).to eq("888-888-8888")
      end
      it "should have a recipient_fax "do
      expect(@fax_record.recipient_fax).to eq("777-777-7777")
      end
      it "should have a fax_id "do
      expect(@fax_record.fax_id).to eq("10")
      end
      it "should have a fax_success "do
      expect(@fax_record.fax_success).to eq(1)
      end
      it "should have a updated_by_initializer "do
      expect(@fax_record.updated_by_initializer).to eq(true)
      end
      it "should have a updated_by_initializer "do
      expect(@fax_record.send_fax_queue_id).to eq('123456789')
      end
      it "should have a updated_by_initializer "do
      expect(@fax_record.SendFaxQueueId).to eq('123456789123456789')
      end
  end
end
