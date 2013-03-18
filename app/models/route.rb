class Route < ActiveRecord::Base
  has_many :trips, :foreign_key => "route_id", :primary_key => "route_id"

  scope :for_route_id, lambda { |r_id|
    where(:route_id => r_id).
      includes(:trips => [:shape_points, { :stop_times => :stop }])
  }

  def shapes
    trips.map(&:geometry)
  end

  def self.by_route_id(r_id)
    self.for_route_id(r_id).first
  end

  def to_param
    self.route_id
  end
end
