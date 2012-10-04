class CreateStopTimeArrivals < ActiveRecord::Migration
  def up
    create_table :stop_time_arrivals do |t|
      t.integer :stop_time_id, :null => false
      t.integer :time, :null => false
    end

    change_table :stop_time_arrivals do |t|
      t.foreign_key :stop_times
    end

    add_index :stop_time_arrivals, :stop_time_id
    add_index :stop_time_arrivals, :time
  end

  def down
    drop_table :stop_time_arrivals
  end
end
