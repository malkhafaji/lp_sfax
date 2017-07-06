class AddNewColumnToAttachments < ActiveRecord::Migration[5.0]
  def up
    add_column :attachments, :file_unique_key, :string
  end

  def down
    remove_column :attachments, :file_unique_key
  end
end
