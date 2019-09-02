class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.text :short_desc
      t.text :long_desc

      t.timestamps
    end
  end
end
