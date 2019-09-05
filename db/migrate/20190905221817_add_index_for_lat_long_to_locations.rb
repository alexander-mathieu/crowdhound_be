class AddIndexForLatLongToLocations < ActiveRecord::Migration[5.2]
  def change
    add_index :locations, :lat
    add_index :locations, :long
  end
end
