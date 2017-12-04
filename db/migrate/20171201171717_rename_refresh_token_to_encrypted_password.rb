class RenameRefreshTokenToEncryptedPassword < ActiveRecord::Migration[5.0]
  def change
    rename_column :users, :refresh_token, :encrypted_password
    add_column :users, :timeout, :integer
  end
end
