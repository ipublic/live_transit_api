class Route < ActiveRecord::Base
  has_many :trips, :foreign_key => "route_id", :primary_key => "route_id"
end
