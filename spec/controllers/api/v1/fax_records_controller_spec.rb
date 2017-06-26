require 'rails_helper'
RSpec.describe Api::V1::FaxRecordsController, type: :controller do
  before :each do
    FakeWeb.allow_net_connect = false
  end
  describe 'send fax' do
    before :each do
      FakeWeb.register_uri(:get, "#{ENV['file_service_path']}/api/v1/documents/1?checksum=xxxxxxx", body: '{"id": 9,
          "file": { "url": "http://example.com/test_fax_file.pdf"},
          "original_file_name": "test_fax_file.pdf"}')
      FakeWeb.register_uri(:post, ENV['fax_server_url'], body: "hello")    
    end
    it 'should send fax with valid params' do
      post :send_fax, {"recipient_name"=>"David Adjuster", "recipient_number"=>"12242144414", "Attachments"=>"[file_id=1,checksum=xxxxxxx+]", "FaxDispositionURL"=>"https://dcm-test-aqattan.c9users.io/receive_re"}
      Rails.logger.debug "==================+#{response.body}"
      expect(response).to have_http_status(200)
    end
  end

end
