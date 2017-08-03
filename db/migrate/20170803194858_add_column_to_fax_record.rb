class AddColumnToFaxRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :fax_records, :resend, :integer, default: 0
  end
end
