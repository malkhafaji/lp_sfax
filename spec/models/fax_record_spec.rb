require 'rails_helper'

RSpec.describe FaxRecord, type: :model do
# describe FaxRecord do
#   let!(:fax_records) do
#     [FaxRecord.create, FaxRecord.create, FaxRecord.create]
#   end
#   it "uses match_array to match a scope " do
#     expect(FaxRecord.all).to match_array(fax_records)
#   end
# end
# describe '#export' do
#   it 'is required' do
#     @fax_record.export = nil
#     @fax_record.valid?
#     expect(@fax_record.errors[:export].size).to eq(1)
#   end
# end
  # it " should have valid recipient_number " do
  #    fax_record = create (:fax_record , recipient_number: "123456789", recipient_number: "123456789")
  #    expect(organization).to be_invalid
  #  end
# describe file_extention , 'Validations' do
#   VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
#   it { should allow_value("lol.gmail.com").for(:email , format: { with: VALID_EMAIL_REGEX })}
#   it { should_not allow_value("Inv4lid").for(:email , format: { with: VALID_EMAIL_REGEX })}
# end
# describe "validates_format_of recipient_number" do
#  recipient_number = /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/
#   it { should validates_format_of(:recipient_number ).for(:recipient_number , format: { with: recipient_number  })}
# end
# describe '#recipient_name' do
#     it "should validate presence (message: "Recipitent Name should not be empty")"
#   end

# it 'is accessible' do
#     fax_record = FaxRecord.create!(recipient_name:  'recipient_name')
#     expect(fax_record).to eq(FaxRecord.last)
#   end

# describe '#self.paginated_fax_record(params)'
# it "returen @page plus 1" do
# assigin (:page, 5)
# expect(Model.next_page).to eq(6)
#   end
# it "is vaild only with 10 records per page in the fax_list" do
#   result =  FaxRecord.paginated_fax_record(:perpage => '10', :page => '1')
#   expect (result).to eq(10)
#   expect (result.count).to eq(10)
#    # expect (FaxRecord.paginated_fax_record[:perpage => '10', :page => '1']).to be true
# end
# result =  FaxRecord.paginated_fax_record([:perpage => '10', :page => '1'])
# expect (result).to eq(10)
# expect (result.count).to eq(10)

#   describe '#self.to_csv(options = {}' do

#     it { expect be_valid (:file_extention) ==("xls,csv") }
# end



#--------------------------up portion is a test--------------- 
describe 'recipient_number' do
    it { expect be_valid (:recipient_number) ==( /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/) }
    it { expect be_valid (:recipient_number) ==(12345678912 ) }
    it { should be_invalid  (:recipient_number) ==( "yuienidn9") }
end



# describe "when recipient_number format is valid" do
#     it "should be valid" do
#       fax_record_recipient_number = /\(?([0-9]{3})\)?([ .-]?)([0-9]{3})\2([0-9]{4})/
#         FaxRecord.recipient_number = 1234567812
#         expect(@fax_record).to be_valid
      
#     end
#   end


  describe 'recipient_name' do
    it { expect be_valid (:message) ==("Recipitent Name should not be empty"  ) }
    it { expect be_invalid (:message) ==("bla bla bla"  ) }
  end
#######################################
describe "paginated" do 
  before do
    @fax_records = {:perpage => '10', :page => '1'}
  end 
  it 'prooperly retrieves a value given a key 'do 
  expect(:perpage) == 10
  expect(:page) == 1
  
end
# it 'throws an error when a key is requested that dose not exist in the hash'do
# expect(:perpage).to raise_error(invalid)
#  end
end 
#########
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
