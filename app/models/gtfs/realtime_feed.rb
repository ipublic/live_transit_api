class Gtfs::RealtimeFeed
  attr_reader :trip_updates
  attr_reader :vehicle_positions

  def self.fetch
    l_time = Time.now
    time_threshold = l_time - 30.minutes
     vehicles = VehiclePosition.with_deviation(:include_docs => true).docs.reject do |veh|
       veh.last_position_time < time_threshold
     end
    [l_time, self.new(Gtfs::TripUpdate.all(vehicles), vehicles, l_time)]
  end

  def initialize(t_updates, v_positions, t_stamp)
    @trip_updates = t_updates
    @vehicle_positions = v_positions
    @timestamp = t_stamp
  end

  def binary_feed
    feed = TransitRealtime::FeedMessage.new({
      :header => TransitRealtime::FeedHeader.new({
        :gtfs_realtime_version => "1.0",
        :incrementality => TransitRealtime::FeedHeader::Incrementality::FULL_DATASET,
        :timestamp => @timestamp.to_i
      }),
      :entity => @trip_updates.map(&:feed) + @vehicle_positions.map(&:feed)
    })
    out_io = StringIO.new
    ProtocolBuffers::Encoder.encode(out_io, feed)
    out_io.string
  end

end
