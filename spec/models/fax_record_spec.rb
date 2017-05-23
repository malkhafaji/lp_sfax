require 'rails_helper'

RSpec.describe FaxRecord, type: :model do


describe 'recipient_number' do
    it { expect be_valid (:recipient_number) ==( /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/) }
    it { expect be_valid (:recipient_number) ==(12345678912 ) }
    it { should be_invalid  (:recipient_number) ==( "yuienidn9") }
end


  describe 'recipient_name' do
    it { expect be_valid (:message) ==("Recipitent Name should not be empty"  ) }
    it { expect be_invalid (:message) ==("bla bla bla"  ) }
  end
#
describe "paginated" do 
  before do
    @fax_records = {:perpage => '10', :page => '1'}
  end 
  it 'prooperly retrieves a value given a key 'do 
  expect(:perpage) == 10
  expect(:page) == 1
  
 end
end 
#
  describe 'is vaild only with 10 records per page in the fax_list.size' do
    it { expect be_valid (:perpage) ==("10") }
    it { expect be_valid (:page) ==("1") }
    it { expect be_invalid (:perpage) ==("5") }
    it { expect be_invalid (:page) ==("2") }
  end
context 'check columns exsitence' do
     it { is_expected.to respond_to :recipient_name }
     it { is_expected.to respond_to :recipient_number }
     it { is_expected.to respond_to :file_path }
     it { is_expected.to respond_to :client_receipt_date}
     it { is_expected.to respond_to :status }
     it { is_expected.to respond_to :message }
     it { is_expected.to respond_to :send_confirm_date}
     it { is_expected.to respond_to :vendor_confirm_date}
 end


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
  end
end
