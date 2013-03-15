class CreateShapePoints < ActiveRecord::Migration
  def change
    create_table :shape_points do |t|
      t.string :shape_id, :limit => 255, :null => false
      t.float :shape_pt_lat, :null => false
      t.float :shape_pt_lon, :null => false
      t.integer :shape_pt_sequence, :null => false
      t.float :shape_dist_traveled, :null => true
    end

    add_index :shape_points, :shape_id
    add_index :shape_points, :shape_pt_sequence
    add_index :shape_points, :shape_pt_lat
    add_index :shape_points, :shape_pt_lon
  end

end
