class Features::Stop < ActiveRecord::Base
  attr_accessible :stop_id, :geometry, :stop_code, :stop_name, :stop_desc, :zone_id, :stop_url, 
                  :location_type, :parent_station, :stop_timezone, :wheelchair_boarding
                  
  has_many :stop_times, :foreign_key => "stop_id", :primary_key => "stop_id"
  set_rgeo_factory_for_column(:geometry, RGeo::Geographic.spherical_factory(:srid => 4326))
  
  default_scope joins(:stop_times)  # Eager load -- if it makes sense?
end
