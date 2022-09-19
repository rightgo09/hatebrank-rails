class CreateDbHatebRsses < ActiveRecord::Migration[7.0]
  def change
    create_table :hateb_rsses do |t|
      t.integer :yyyymmddhh
      t.string :link
      t.string :category
      t.string :title
      t.integer :bookmarkcount
      t.string :description

      t.timestamps null: false
    end
  end
end
