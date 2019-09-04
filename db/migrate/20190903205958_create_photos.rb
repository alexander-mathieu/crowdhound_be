class CreatePhotos < ActiveRecord::Migration[5.2]
  def change
    create_table :photos do |t|
      t.belongs_to :photoable, polymorphic: true
      t.string :source_url

      t.timestamps
    end
    add_index :photos, [:photoable_id, :photoable_type]
  end
end
