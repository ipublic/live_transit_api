class Gtfs::TripUpdate
  attr_reader :trip_id
  attr_reader :stop_time_updates
  attr_reader :timestamp

  def self.all(vehicles)
     stus = vehicles.map do |v|
       Gtfs::StopTimeUpdate.new(v.trip_id, v.previous_sequence, v.predicted_deviation)
     end
     stus.group_by(&:trip_id).map do |(k,v)|
       Gtfs::TripUpdate.new(k, v)
     end
  end

  def initialize(t_id, st_updates)
    @trip_id = t_id
    @stop_time_updates = st_updates
  end

  def gtfs_id
   "trip_#{trip_id}_stop_time_update"
  end

  def feed
    TransitRealtime::FeedEntity.new({
      :id => gtfs_id,
      :trip_update => TransitRealtime::TripUpdate.new({
        :trip => TransitRealtime::TripDescriptor.new({
          :trip_id => @trip_id
        }),
        :stop_time_update => @stop_time_updates.map(&:feed)
      })
    })
  end
  
end
