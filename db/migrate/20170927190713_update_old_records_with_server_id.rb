class UpdateOldRecordsWithServerId < ActiveRecord::Migration[5.0]
  def change
    FaxRecord.where(callback_server_id: nil).where.not(callback_url: nil).find_each do |fax|
      callback_server = CallbackServer.find_by_update_url(fax.callback_url)
      fax.update_attributes(callback_server_id: callback_server.id)
      puts "Fax record #{fax.id} has been updated"
    end
  end
end
