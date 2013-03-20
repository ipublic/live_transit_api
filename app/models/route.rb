class Route < ActiveRecord::Base
  has_many :trips, :foreign_key => "route_id", :primary_key => "route_id"

  scope :for_route_id, lambda { |r_id|
      includes(:trips => [:shape_points, { :stop_times => :stop }]).
        where(:route_id => r_id)
  }

  def shapes
    # Fix this once we move to 1.9.3
    # trips.uniq(&:shape_id).map(&:geometry)
    (trips.inject([]) do |memo, trip|
      memo.map(&:shape_id).include?(trip.shape_id) ? memo : memo + [trip]
    end).map(&:geometry)
  end

  def self.by_route_id(r_id)
    self.for_route_id(r_id).first
  end

  def to_param
    self.route_id
  end
end
