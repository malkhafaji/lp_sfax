every '*/5 9-17,0 * * *' do
  system "rake check_fax_response"
  system "rake sendback_final_response_to_client"
end
