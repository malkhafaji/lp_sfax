class CreateAttachments < ActiveRecord::Migration[5.0]
  def change
    create_table :attachments do |t|
      t.integer :fax_record_id
      t.integer :file_id
      t.string :checksum

      t.timestamps
    end
  end
end
