class CreateStopTimeServices < ActiveRecord::Migration
  def up
    create_table :stop_time_services, { :id => false } do |t|
      t.integer :stop_time_id, :null => false
      t.string :stop_id, :limit => 255, :null => false
      t.string :service_id, :limit => 128, :null => false
      t.integer :arrival_time
      t.integer :departure_time
    end

    add_index :stop_time_services, :stop_time_id
    add_index :stop_time_services, :stop_id
    add_index :stop_time_services, :arrival_time
    add_index :stop_time_services, :departure_time
    add_index :stop_time_services, :service_id
  end

  def down
    drop_table :stop_time_services
  end
end
