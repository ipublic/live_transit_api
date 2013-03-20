class StopTimeEvent < ActiveRecord::Base
  belongs_to :stop_time, :foreign_key => "stop_time_id"
  belongs_to :stop, :foreign_key => "stop_id", :primary_key => "stop_id"

  delegate :route, :to => :stop_time
  delegate :trip, :to => :stop_time

  scope :for_stop_and_arrival_time, lambda { |s_id, t_val|
    where("stop_id = ? and arrival_time > ?", s_id, t_val).
      order("arrival_time").
      includes(:stop_time => { :trip => :route })
  }

  scope :for_stop_and_trips_between, lambda { |s_id, t_ids, s_val, e_val|
    where("stop_time_events.stop_id = ? and stop_times.trip_id in (?) and stop_time_events.arrival_time > ? and stop_time_events.arrival_time < ?", s_id, t_ids, s_val, e_val).
      joins(:stop_time => { :trip => :route })
  }
end
