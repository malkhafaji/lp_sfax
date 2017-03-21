require 'rails_helper'

RSpec.describe FaxRecordsController, type: :controller do

    list_of_all_actions_in_fax_records_controller = FaxRecordsController.action_methods.sort
    describe "names for actions for the application should be the same in the test" do


      it 'Search for action with name filtered_fax_records' do
        expect(list_of_all_actions_in_fax_records_controller.grep(/index/)).to eq(['index'])
      end

      it 'Search for action with name to_csv' do
        expect(list_of_all_actions_in_fax_records_controller.grep(/export/)).to eq(['export'])
      end

      it 'Search for action with name paginated_fax_record' do
        expect(list_of_all_actions_in_fax_records_controller.grep(/send_fax/)).to eq(['send_fax'])
      end

    end
end
