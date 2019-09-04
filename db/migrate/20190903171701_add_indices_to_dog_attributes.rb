class AddIndicesToDogAttributes < ActiveRecord::Migration[5.2]
  def change
    add_index :dogs, :activity_level
    add_index :dogs, :birthdate
    add_index :dogs, :breed
    add_index :dogs, :weight
  end
end
