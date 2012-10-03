class CreateStops < ActiveRecord::Migration
  def up
    create_table :stops do |t|
      t.string :stop_id, :limit => 255, :null => false
      t.string :stop_code, :limit => 255, :null => true
      t.string :stop_name, :limit => 512, :null => false
      t.text :stop_desc
      t.float :stop_lat, :null => false
      t.float :stop_lon, :null => false
      t.string :zone_id, :limit => 255, :null => true
      t.string :stop_url, :limit => 1024, :null => true
      t.integer :location_type, :null => true
      t.string :parent_station, :limit => 255, :null => true
      t.string :stop_timezone, :limit => 255, :null => true
      t.integer :wheelchair_boarding, :null => true
    end

    add_index :stops, :stop_id, :unique => true
    add_index :stops, :stop_code
    add_index :stops, :stop_lat
    add_index :stops, :stop_lon
  end

  def down
    drop_table :stops
  end
end
