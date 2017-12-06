class AddClientIdToFaxRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :fax_records, :client_id, :integer
  end
end
