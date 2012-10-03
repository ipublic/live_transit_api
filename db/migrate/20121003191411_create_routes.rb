class CreateRoutes < ActiveRecord::Migration
  def up
    create_table :routes do |t|
      t.string :route_id, :limit => 255, :null => false
      t.string :agency_id, :limit => 255, :null => true
      t.string :route_short_name, :limit => 255, :null => false
      t.string :route_long_name, :limit => 1024, :null => false
      t.text :route_long_name
      t.integer :route_type, :null => false
      t.string :route_url, :limit => 1024, :null => true
      t.string :route_color, :limit => 255, :null => true
      t.string :route_text_color, :limit => 255, :null => true
    end
    change_table :routes do |t|
      t.foreign_key :agencies, :column => :agency_id, :primary_key => :agency_id
    end
    add_index :routes, :agency_id
    add_index :routes, :route_id, :unique => true
    add_index :routes, :route_long_name
    add_index :routes, :route_short_name
  end

  def down
    drop_table :routes
  end
end
