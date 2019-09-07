class AddGoogleTokenToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :google_token, :string
    add_index :users, :google_token
  end
end
