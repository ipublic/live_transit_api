class StopTimeEvent < ActiveRecord::Base
  belongs_to :stop_time, :foreign_key => "stop_time_id", :inverse_of => :stop_time_events
  belongs_to :stop, :foreign_key => "stop_id", :primary_key => "stop_id"

  delegate :route, :to => :stop_time
  delegate :trip, :to => :stop_time

  scope :for_stop_and_arrival_time, lambda { |s_id, t_val|
    where("stop_time.stop_sequence <> trip.last_stop_sequence and stop_id = ? and arrival_time > ?", s_id, t_val).
      order("arrival_time").
      includes(:stop_time => [:stop, { :trip => :route }])
  }

  scope :for_stop_and_blocks_between, lambda { |s_id, b_ids, s_val, e_val|
    where("stop_time.stop_sequence <> trip.last_stop_sequence and stop_time_events.stop_id = ? and trips.block_id in (?) and stop_time_events.arrival_time > ? and stop_time_events.arrival_time < ?", s_id, b_ids, s_val, e_val).
      joins(:stop_time => [:stop, { :trip => :route }])
  }
end
