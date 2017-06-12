class RemoveFilePathFromFaxRecords < ActiveRecord::Migration[5.0]
  def change
    remove_column :fax_records, :file_path, :string
  end
end
