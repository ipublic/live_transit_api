class Features::TripShape < ActiveRecord::Base
  attr_accessible :trip_shape_id, :geometry, :trip_shape_dist_traveled
  
  has_many :trips
  set_rgeo_factory_for_column(:geometry, RGeo::Geographic.spherical_factory(:srid => 4326))
  
  
end
