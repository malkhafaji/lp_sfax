class AddFileReferenceToAttachments < ActiveRecord::Migration[5.0]
  def change
    add_column :attachments, :file_reference, :string
  end
end
