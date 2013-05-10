class CreateFeaturesStops < ActiveRecord::Migration
  def change
    create_table :features_stops do |t|
	    t.string :stop_id, null: false
      t.point :stop_latlon, geographic: true, null: false
	    t.string :stop_code, null: true
	    t.string :stop_name, null: false
	    t.text :stop_desc
	    t.string :zone_id, null: true
	    t.string :stop_url, null: true
	    t.integer :location_type, default: 0
	    t.string :parent_station, null: true
	    t.string :stop_timezone, null: true
	    t.integer :wheelchair_boarding, default: 0
	
      t.timestamps
    end
    
    change_table :features_stops do |t|
      t.index :stop_latlon, spatial: true
    end

    add_index :features_stops, :stop_id, unique: true
    add_index :features_stops, :stop_code
    add_index :features_stops, :zone_id

  end
end
