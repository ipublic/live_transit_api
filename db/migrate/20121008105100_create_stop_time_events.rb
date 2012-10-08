class CreateStopTimeEvents < ActiveRecord::Migration
  def up
    create_table :stop_time_events, { :id => false } do |t|
      t.integer :stop_time_id, :null => false
      t.string :stop_id, :limit => 255, :null => false
      t.integer :arrival_time
      t.integer :departure_time
    end
  end

  def down
    drop_table :stop_time_events
  end
end
