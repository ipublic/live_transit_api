class CreateFeaturesTripShapes < ActiveRecord::Migration
  def change
    create_table :features_trip_shapes do |t|
	    t.string :trip_shape_id, null: false
      t.line_string :geometry, geographic: true, null: false
	    t.float :trip_shape_dist_traveled, default: 0.0

      t.timestamps
    end

    change_table :features_trip_shapes do |t|
      t.index :geometry, spatial: true
    end

  end
end
