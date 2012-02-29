class Gtfs::StopTimeUpdate
  attr_reader :stop_sequence
  attr_reader :arrival_delay
  attr_reader :trip_id

  def initialize(t_id, seq, delay)
    @trip_id = t_id
    @stop_sequence = seq
    # Flip the sign convention and turn from minutes => seconds
    @arrival_delay = delay * -60
  end
end
