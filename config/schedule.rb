every '0,5,10,15,20,25,30,35,40,45,50,55 * * * *' do
  rake 'check_fax_response'
  rake 'sendback_final_response_to_client'
end

every :hour do
  rake 'resend_fax_with_errors'
end
