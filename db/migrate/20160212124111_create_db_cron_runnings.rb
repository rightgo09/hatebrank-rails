class CreateDbCronRunnings < ActiveRecord::Migration[7.0]
  def change
    create_table :cron_runnings do |t|
      t.integer :yyyymmddhh

      t.timestamps null: false
    end
  end
end
