class CreateStopTimes < ActiveRecord::Migration
  def up
    create_table :stop_times do |t|
      t.string :stop_id, :limit => 255, :null => false
      t.string :trip_id, :limit => 255, :null => false
      t.integer :stop_sequence, :null => false
      t.integer :arrival_time, :null => false
      t.integer :departure_time, :null => false
      t.string :stop_headsign, :limit => 512, :null => true
      t.integer :pickup_type, :null => true
      t.integer :drop_off_type, :null => true
      t.float :shape_dist_traveled, :null => true
    end
    change_table :stop_times do |t|
      t.foreign_key :stops, :column => :stop_id, :primary_key => :stop_id
      t.foreign_key :trips, :column => :trip_id, :primary_key => :trip_id
    end

    add_index :stop_times, :stop_id
    add_index :stop_times, :trip_id
    add_index :stop_times, :arrival_time
    add_index :stop_times, :departure_time
  end

  def down
    drop_table :stop_times
  end
end
