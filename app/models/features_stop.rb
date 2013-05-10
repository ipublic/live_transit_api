class FeaturesStop < ActiveRecord::Base
  attr_accessible :stop_id, :stop_latlon, :stop_code, :stop_name, :stop_desc, :zone_id, :stop_url, 
                  :location_type, :parent_station, :stop_timezone, :wheelchair_boarding
                  
  has_many :stop_times, :foreign_key => "stop_id", :primary_key => "stop_id"
end
