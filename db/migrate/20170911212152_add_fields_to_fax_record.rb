class AddFieldsToFaxRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :fax_records, :e_sk, :integer
    add_column :fax_records, :let_sk, :integer
    add_column :fax_records, :type_cd_sk, :integer
    add_column :fax_records, :priority_cd_sk, :integer
  end
end
