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

end
