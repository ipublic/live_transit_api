class StopTime < ActiveRecord::Base
  belongs_to :trip, :foreign_key => "trip_id", :primary_key => "trip_id", :inverse_of => :stop_times
  belongs_to :stop, :foreign_key => "stop_id", :primary_key => "stop_id"

  has_many :stop_time_events, :foreign_key => "stop_time_id", :primary_key => "stop_time_id"

  delegate :route, :to => :trip
  delegate :block_id, :to => :trip
end
