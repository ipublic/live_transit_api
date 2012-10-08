class CreateTripDays < ActiveRecord::Migration
  def up
    create_table :trip_days do |t|
      t.integer :service_id, :null => false
      t.integer :day, :null => false
    end

    add_index :trip_days, :service_id
    add_index :trip_days, :day
  end

  def down
    drop_table :trip_days
  end
end
