require 'rails_helper'

RSpec.describe 'FaxRecordschema', type: :schema do

  list_of_schema_columns = FaxRecord.column_names

  describe "one of the schema columns should be named as SendFaxQueueId" do
    it 'Search for column with name SendFaxQueueId' do
      expect(list_of_schema_columns.grep('SendFaxQueueId')).to eq(['SendFaxQueueId'])
    end
    it 'Search for column with name attempts' do
      expect(list_of_schema_columns.grep('attempts')).to eq(['attempts'])
    end
    it 'Search for column with name client_receipt_date' do
      expect(list_of_schema_columns.grep('client_receipt_date')).to eq(['client_receipt_date'])
    end
    it 'Search for column with name barcode_items' do
      expect(list_of_schema_columns.grep('barcode_items')).to eq(['barcode_items'])
    end
    it 'Search for column with name created_at' do
      expect(list_of_schema_columns.grep('created_at')).to eq(['created_at'])
    end
    it 'Search for column with name error_code' do
      expect(list_of_schema_columns.grep('error_code')).to eq(['error_code'])
    end
    it 'Search for column with name fax_date_iso' do
      expect(list_of_schema_columns.grep('fax_date_iso')).to eq(['fax_date_iso'])
    end
    it 'Search for column with name fax_date_utc' do
      expect(list_of_schema_columns.grep('fax_date_utc')).to eq(['fax_date_utc'])
    end
    it 'Search for column with name fax_id' do
      expect(list_of_schema_columns.grep('fax_id')).to eq(['fax_id'])
    end
    it 'Search for column with name fax_pages' do
      expect(list_of_schema_columns.grep('fax_pages')).to eq(['fax_pages'])
    end
    it 'Search for column with name fax_success' do
      expect(list_of_schema_columns.grep('fax_success')).to eq(['fax_success'])
    end
    it 'Search for column with name is_success' do
      expect(list_of_schema_columns.grep('is_success')).to eq(['is_success'])
    end
    it 'Search for column with name max_fax_response_check_tries' do
      expect(list_of_schema_columns.grep('max_fax_response_check_tries')).to eq(['max_fax_response_check_tries'])
    end
    it 'Search for column with name out_bound_fax_id' do
      expect(list_of_schema_columns.grep('out_bound_fax_id')).to eq(['out_bound_fax_id'])
    end
    it 'Search for column with name pages' do
      expect(list_of_schema_columns.grep('pages')).to eq(['pages'])
    end
    it 'Search for column with name recipient_fax' do
      expect(list_of_schema_columns.grep('recipient_fax')).to eq(['recipient_fax'])
    end
    it 'Search for column with name recipient_number' do
      expect(list_of_schema_columns.grep('recipient_number')).to eq(['recipient_number'])
    end
    it 'Search for column with name recipient_name' do
      expect(list_of_schema_columns.grep('recipient_name')).to eq(['recipient_name'])
    end
    it 'Search for column with name message' do
      expect(list_of_schema_columns.grep('message')).to eq(['message'])
    end
    it 'Search for column with name id' do
      expect(list_of_schema_columns.grep('id')).to eq(['id'])
    end
    it 'Search for column with name result_code' do
      expect(list_of_schema_columns.grep('result_code')).to eq(['result_code'])
    end
    it 'Search for column with name result_message' do
      expect(list_of_schema_columns.grep('result_message')).to eq(['result_message'])
    end
    it 'Search for column with name send_confirm_date' do
      expect(list_of_schema_columns.grep('send_confirm_date')).to eq(['send_confirm_date'])
    end
    it 'Search for column with name send_fax_queue_id' do
      expect(list_of_schema_columns.grep('send_fax_queue_id')).to eq(['send_fax_queue_id'])
    end
    it 'Search for column with name sender_fax' do
      expect(list_of_schema_columns.grep('sender_fax')).to eq(['sender_fax'])
    end
    it 'Search for column with name status' do
      expect(list_of_schema_columns.grep('status')).to eq(['status'])
    end
    it 'Search for column with name tracking_code' do
      expect(list_of_schema_columns.grep('tracking_code')).to eq(['tracking_code'])
    end
    it 'Search for column with name updated_at' do
      expect(list_of_schema_columns.grep('updated_at')).to eq(['updated_at'])
    end
    it 'Search for column with name updated_by_initializer' do
      expect(list_of_schema_columns.grep('updated_by_initializer')).to eq(['updated_by_initializer'])
    end
    it 'Search for column with name vendor_confirm_date' do
      expect(list_of_schema_columns.grep('vendor_confirm_date')).to eq(['vendor_confirm_date'])
    end
    it 'Search for column with name watermark_id' do
      expect(list_of_schema_columns.grep('watermark_id')).to eq(['watermark_id'])
    end
  end

  hash_of_schema_columns_names_and_types = FaxRecord.attribute_names.map{|n|[n.to_sym,FaxRecord.type_for_attribute(n).type]}.to_h
  p hash_of_schema_columns_names_and_types = FaxRecord.attribute_names.map{|n|[n.to_sym,FaxRecord.type_for_attribute(n).type]}.to_h
  describe "checking the types for the schema columns" do
    it 'recipient_name should be type string' do
      expect(hash_of_schema_columns_names_and_types[:recipient_name]).to eq(:string)
    end
    it 'recipient_number should be type string' do
      expect(hash_of_schema_columns_names_and_types[:recipient_number]).to eq(:string)
    end
    it 'file_path should be type string' do
      expect(hash_of_schema_columns_names_and_types[:file_path]).to eq(:string)
    end
    it 'status should be type string' do
      expect(hash_of_schema_columns_names_and_types[:status]).to eq(:string)
    end
    it 'SendFaxQueueId should be type string' do
      expect(hash_of_schema_columns_names_and_types[:SendFaxQueueId]).to eq(:string)
    end
    it 'message should be type string' do
      expect(hash_of_schema_columns_names_and_types[:message]).to eq(:string)
    end
    it 'send_fax_queue_id should be type string' do
      expect(hash_of_schema_columns_names_and_types[:send_fax_queue_id]).to eq(:string)
    end
    it 'is_success should be type string' do
      expect(hash_of_schema_columns_names_and_types[:is_success]).to eq(:string)
    end
    it 'result_message should be type string' do
      expect(hash_of_schema_columns_names_and_types[:result_message]).to eq(:string)
    end
    it 'recipient_fax should be type string' do
      expect(hash_of_schema_columns_names_and_types[:recipient_fax]).to eq(:string)
    end
    it 'tracking_code should be type string' do
      expect(hash_of_schema_columns_names_and_types[:tracking_code]).to eq(:string)
    end
    it 'fax_id should be type string' do
      expect(hash_of_schema_columns_names_and_types[:fax_id]).to eq(:string)
    end
    it 'watermark_id should be type string' do
      expect(hash_of_schema_columns_names_and_types[:watermark_id]).to eq(:string)
    end
    it 'sender_fax should be type string' do
      expect(hash_of_schema_columns_names_and_types[:sender_fax]).to eq(:string)
    end
    it 'barcode_items should be type string' do
      expect(hash_of_schema_columns_names_and_types[:barcode_items]).to eq(:string)
    end
    it 'out_bound_fax_id should be type string' do
      expect(hash_of_schema_columns_names_and_types[:out_bound_fax_id]).to eq(:string)
    end
    it 'pages should be type integer' do
      expect(hash_of_schema_columns_names_and_types[:pages]).to eq(:integer)
    end
    it 'result_code should be type integer' do
      expect(hash_of_schema_columns_names_and_types[:result_code]).to eq(:integer)
    end
    it 'error_code should be type integer' do
      expect(hash_of_schema_columns_names_and_types[:error_code]).to eq(:integer)
    end
    it 'attempts should be type integer' do
      expect(hash_of_schema_columns_names_and_types[:attempts]).to eq(:integer)
    end
    it 'fax_success should be type integer' do
      expect(hash_of_schema_columns_names_and_types[:fax_success]).to eq(:integer)
    end
    it 'max_fax_response_check_tries should be type integer' do
      expect(hash_of_schema_columns_names_and_types[:max_fax_response_check_tries]).to eq(:integer)
    end
    it 'fax_pages should be type integer' do
      expect(hash_of_schema_columns_names_and_types[:fax_pages]).to eq(:integer)
    end
    it 'updated_by_initializer should be type boolean' do
      expect(hash_of_schema_columns_names_and_types[:updated_by_initializer]).to eq(:boolean)
    end
    it 'fax_date_utc should be type date' do
      expect(hash_of_schema_columns_names_and_types[:fax_date_utc]).to eq(:date)
    end
    it 'vendor_confirm_date should be type date' do
      expect(hash_of_schema_columns_names_and_types[:vendor_confirm_date]).to eq(:date)
    end
    it 'client_receipt_date should be type date' do
      expect(hash_of_schema_columns_names_and_types[:client_receipt_date]).to eq(:date)
    end
    it 'send_confirm_date should be type date' do
      expect(hash_of_schema_columns_names_and_types[:send_confirm_date]).to eq(:date)
    end
    it 'fax_date_iso should be type date' do
      expect(hash_of_schema_columns_names_and_types[:fax_date_iso]).to eq(:date)
    end
    it 'created_at should be type datetime' do
      expect(hash_of_schema_columns_names_and_types[:created_at]).to eq(:datetime)
    end
    it 'updated_at should be type datetime' do
      expect(hash_of_schema_columns_names_and_types[:updated_at]).to eq(:datetime)
    end
  end
end
