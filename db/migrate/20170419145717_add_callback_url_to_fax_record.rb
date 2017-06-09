class AddCallbackUrlToFaxRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :fax_records, :callback_url, :string
  end
end
