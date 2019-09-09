class RenameGoogleTokenInUsers < ActiveRecord::Migration[5.2]
  def change
    rename_column :users, :google_token, :token
  end
end
