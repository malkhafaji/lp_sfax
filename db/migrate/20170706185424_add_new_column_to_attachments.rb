class AddNewColumnToAttachments < ActiveRecord::Migration[5.0]
  def up
    add_column :attachments, :file_key, :string, index: :true
  end

  def down
    remove_column :attachments, :file_key
  end
end
