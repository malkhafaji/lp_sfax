unless Rails.env == 'production'
  5.times do
    CallbackServer.create(name: Faker::Name.title, url: Faker::Internet.url, update_url: Faker::Internet.url)
  end

  CallbackServer.all.each do |callback_server|
    1000.times do
      FaxRecord.create(callback_server_id: callback_server.id, created_at: Faker::Time.between(4.months.ago, Date.today, :all),
      recipient_number: Faker::PhoneNumber.cell_phone, recipient_name: Faker::Name.name, status: Faker::Boolean.boolean(0.9),
      send_fax_queue_id: SecureRandom.hex(10), is_success: Faker::Boolean.boolean(0.95), pages: Faker::Number.number(2))
    end
  end
  FaxRecord.where(result_message: nil, is_success: 'f').find_each do |record|
      s = ['Success', 'Fax Number Busy', 'Transmission not completed', 'No Faxtone', 'Other'].sample
      record.update_attributes(result_message: s, client_receipt_date: Faker::Time.between(4.months.ago, Date.today, :all))
  end

  FaxRecord.where(result_message: nil, is_success: 't').update_all(result_message: 'Success', client_receipt_date: Faker::Time.between(4.months.ago, Date.today, :all))
end
