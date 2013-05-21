class StopTimeEvent < ActiveRecord::Base
  belongs_to :stop_time, :foreign_key => "stop_time_id", :inverse_of => :stop_time_events, :include => {:trip => :route}
  belongs_to :stop, :foreign_key => "stop_id", :primary_key => "stop_id"

  delegate :route, :to => :stop_time
  delegate :trip, :to => :stop_time

  delegate :block_id, :to => :stop_time

  scope :for_stop_and_arrival_time, lambda { |s_id, t_val|
    where("stop_times.stop_sequence <> trip.last_stop_sequence and stop_id = ? and stop_time_events.arrival_time > ?", s_id, t_val).
      order("stop_time_events.arrival_time").
      joins(:stop, {:stop_time => [:stop, { :trip => :route }]})
  }

  scope :for_stops_and_arrival_time_with_blocks, lambda { |stop_ids, n_val, s_val, e_val, block_ids|
    joins({:stop_time => [{ :trip => :route }, :stop]}, :stop).
      where("stop_time_events.stop_id in (?) and
            stop_times.stop_sequence <> trips.last_stop_sequence and (
            (
            (stop_time_events.arrival_time > ? and stop_time_events.arrival_time < ?)
            AND
            (trips.block_id not in (?))
            )
            OR (
            (stop_time_events.arrival_time > ? and stop_time_events.arrival_time < ?)
            AND
            (trips.block_id in (?))
            ))", stop_ids, n_val, e_val, block_ids, s_val, e_val, block_ids).
    includes({:stop_time => [{ :trip => :route }, :stop]}, :stop)
  }

  scope :for_arrival_time_with_blocks, lambda { |n_val, s_val, e_val, block_ids|
    joins({:stop_time => [{ :trip => :route }, :stop]}, :stop).
      where("stop_times.stop_sequence <> trips.last_stop_sequence and (
            (
            (stop_time_events.arrival_time > ? and stop_time_events.arrival_time < ?)
            AND
            (trips.block_id not in (?))
            )
            OR (
            (stop_time_events.arrival_time > ? and stop_time_events.arrival_time < ?)
            AND
            (trips.block_id in (?))
            ))", n_val, e_val, block_ids, s_val, e_val, block_ids).
    includes({:stop_time => [{ :trip => :route }, :stop]}, :stop) #.
      # order("stop_time_events.arrival_time")
  }

  scope :for_stop_and_blocks_between, lambda { |s_id, b_ids, s_val, e_val|
    where("stop_times.stop_sequence <> trips.last_stop_sequence and stop_time_events.stop_id = ? and trips.block_id in (?) and stop_time_events.arrival_time > ? and stop_time_events.departure_time < ?", s_id, b_ids, s_val, e_val).
      joins(:stop_time => [:stop, { :trip => :route }])
  }

  scope :for_blocks_between, lambda { |b_ids, s_val, e_val|
    where("stop_times.stop_sequence <> trips.last_stop_sequence and trips.block_id in (?) and stop_time_events.arrival_time > ? and stop_time_events.arrival_time < ?", b_ids, s_val, e_val).
      joins(:stop_time => [:stop, { :trip => :route }])
  }
end
