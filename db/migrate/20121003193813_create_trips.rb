class CreateTrips < ActiveRecord::Migration
  def up
    create_table :trips do |t|
      t.string :trip_id, :limit => 255, :null => false
      t.string :route_id, :limit => 255, :null => false
      t.integer :service_id, :null => false
      t.string :trip_headsign, :limit => 512, :null => true
      t.string :trip_short_name, :limit => 512, :null => true
      t.integer :direction_id, :null => true
      t.string :block_id, :limit => 255, :null => false
      t.string :shape_id, :limit => 255, :null => false
      t.integer :last_stop_sequence, :null => true
    end
    change_table :trips do |t|
      t.foreign_key :routes, :column => :route_id, :primary_key => :route_id
    end

    add_index :trips, :trip_id, :unique => true
    add_index :trips, :route_id
    add_index :trips, :service_id
    add_index :trips, :shape_id
    add_index :trips, :last_stop_sequence
  end

  def down
    drop_table :trips
  end
end
