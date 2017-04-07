require 'rails_helper'
RSpec.describe FaxRecordsController, type: :controller do
  
	

  describe "a simple stub with no return value specified" do
    let(:receiver) { double("receiver") }
    it "returns nil" do
      receiver.stub(:message)
      receiver.message.should be(nil)
    end
    it "quietly carries on when not called" do
      receiver.stub(:message)
    end
  end

  describe "a simple stub with a return value" do
  context "specified in a block" do
    it "returns the specified value" do
      receiver = double("receiver")
      receiver.stub(:message) { :return_value }
      receiver.message.should eq(:return_value)
    end
  end
  context "specified in the double declaration" do
    it "returns the specified value" do
      receiver = double("receiver", :message => :return_value)
      receiver.message.should eq(:return_value)
    end
  end
  context "specified with and_return" do
    it "returns the specified value" do
      receiver = double("receiver")
      receiver.stub(:message).and_return(:return_value)
      receiver.message.should eq(:return_value)
    end
  end
end

describe "a stub with no return value specified" do
  let(:collaborator) { double("collaborator") }
  it "returns nil" do
    allow(collaborator).to receive(:message)
    expect(collaborator.message).to be(nil)
  end
end

describe "a stub with a return value" do
  context "specified in a block" do
    it "returns the specified value" do
      collaborator = double("collaborator")
      collaborator.stub(:message) { :value }
      collaborator.message.should eq(:value)
    end
  end
  context "specified with #and_return" do
    it "returns the specified value" do
      collaborator = double("collaborator")
      collaborator.stub(:message).and_return(:value)
      collaborator.message.should eq(:value)
    end
  end
  context "specified with a hash passed to #stub" do
    it "returns the specified value" do
      collaborator = double("collaborator")
      collaborator.stub(:message_1 => :value_1, :message_2 => :value_2)
      collaborator.message_1.should eq(:value_1)
      collaborator.message_2.should eq(:value_2)
    end
  end
  context "specified with a hash passed to #double" do
    it "returns the specified value" do
      collaborator = double("collaborator",
        :message_1 => :value_1,
        :message_2 => :value_2
      )
      collaborator.message_1.should eq(:value_1)
      collaborator.message_2.should eq(:value_2)
    end
  end
end

describe "a double with as_null_object called" do
  let(:null_object) { double('null object').as_null_object }
  it "responds to any method that is not defined" do
    null_object.should respond_to(:an_undefined_method)
  end
  it "allows explicit stubs" do
    null_object.stub(:foo) { "bar" }
    null_object.foo.should eq("bar")
  end
  it "allows explicit expectations" do
    null_object.should_receive(:something)
    null_object.something
  end
  it "supports Array#flatten" do
    null_object = double('foo')
    [null_object].flatten.should eq([null_object])
  end
end

describe "a double receiving to_ary" do
  shared_examples "to_ary" do
    it "can be overridden with a stub" do
      obj.stub(:to_ary) { :non_nil_value }
      obj.to_ary.should be(:non_nil_value)
    end
    it "supports Array#flatten" do
      obj = double('foo')
      [obj].flatten.should eq([obj])
    end
  end
  context "double as_null_object" do
    let(:obj) { double('obj').as_null_object }
    include_examples "to_ary"
  end
  context "double without as_null_object" do
    let(:obj) { double('obj') }
    include_examples "to_ary"
  end
end

  describe "names for actions for the application should be the same in the test" do
    list_of_all_actions_in_fax_records_controller = FaxRecordsController.action_methods.sort
    it 'Search for action with name filtered_fax_records' do
      expect(list_of_all_actions_in_fax_records_controller.grep('index')).to eq(['index'])
    end
    it 'Search for action with name to_csv' do
      expect(list_of_all_actions_in_fax_records_controller.grep('export')).to eq(['export'])
    end
  end

  describe "names for actions for the application should be the same in the test" do
    list_of_all_actions_in_API_V1_fax_records_controller = Api::V1::FaxRecordsController.action_methods.sort
    it 'Search for action with name paginated_fax_record' do
      expect(list_of_all_actions_in_API_V1_fax_records_controller.grep('send_fax')).to eq(['send_fax'])
    end
  end
end
