class CreateUsers < ActiveRecord::Migration[5.0]
  def change
   create_table :users do |t|
     t.string :email
     t.string :name
     t.string :refresh_token
     t.string :access_token
     t.datetime :access_token_expires_at
     t.datetime :last_sign_in_at

     t.timestamps
   end
   add_index :users, :email, unique: true
 end
end
