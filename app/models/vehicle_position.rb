class VehiclePosition < CouchRest::Model::Base
  property :vehicle_id, String
  property :latitude, String
  property :longitude, String
  property :speed, String
  property :heading, String
  property :vehicle_position_date_time, String
  property :incident_date_time, String
  property :last_scheduled_time, String
  property :trip_id, String
  property :last_stop_deviation, Integer
  property :predicted_deviation, Integer
  property :previous_sequence, Integer

  design do
    view :by_vehicle_id
  end

  def calculate_adjusted_stops(trip)
    return([]) if self.predicted_deviation == 63
    allowable_stops = trip.stops.reject do |st|
      st["stop_sequence"] < previous_sequence
    end
    bottom_offset = get_offset(allowable_stops.min { |ast| ast["stop_sequence"] }["arrival_time"])
    schedule_time = parse_mssql_date_time(last_scheduled_time)
    allowable_stops.map do |ast|
      offset = get_offset(ast["arrival_time"]) - bottom_offset - (predicted_deviation * 60)
      ast.merge({ 
        "last_stop_name" => trip.last_stop_name,
        "scheduled_time" => schedule_time - offset
      })
    end
  end

  def parse_mssql_date_time(dt_val)
    DateTime.strptime(dt_val, "%FT%T%:z")
  end

  def get_offset(t_val)
    vals = t_val.split(":").map(&:to_i)
    vals[2] + (vals[1] * 60) + (vals[0] * 60 * 60)
  end

  def self.create_or_update_many(props)
    if props.kind_of?(Array)
      props.map do |prop|
        create_or_update(prop)
      end.last
    else
      create_or_update(props)
    end
  end

  def self.create_or_update(params)
    record = nil
    if !params.nil?
      if !params["NewDataSet"].nil?
        if !params["NewDataSet"]["Table"].nil?
          props = params["NewDataSet"]["Table"]
          rec_id = props['vehicle_id']
          record = self.by_vehicle_id.key(rec_id).first
          if record.nil?
            record = self.create!(props)
          else
            record.update_attributes(props)
          end
        end
      end
    end
    record
  end

end
