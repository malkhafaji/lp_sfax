class CreateCallbackServers < ActiveRecord::Migration[5.0]
  def up
    create_table :callback_servers do |t|
      t.string :name
      t.string :url, index: true, null: false
      t.string :update_url, index: true
      t.integer :insert_port, index: true
      t.timestamps
    end
    add_column :fax_records, :callback_server_id, :integer
  end

  def down
    drop_table :callback_servers
    remove_column :fax_records, :callback_server_id
  end
end
