class VehiclePosition < CouchRest::Model::Base
  self.database = CouchDatabases[:vehicles]

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
    view :by_trip_id
    view :with_deviation, :map=> CouchDocLoader["_design/VehiclePosition/views/with_deviation/map.js"]
    view :by_trip_with_deviation, :map=> CouchDocLoader["_design/VehiclePosition/views/by_trip_with_deviation/map.js"]
  end

  before_save :setup_id

  def setup_id
    self['_id'] = "vehicle_" + self['vehicle_id']
  end

  def last_position_time
    @last_position_time ||= parse_mssql_date_time(self.vehicle_position_date_time)
  end

  def calculate_adjusted_stops(trip)
    return([]) if self.predicted_deviation == 63
    allowable_stops = []
    if self.previous_sequence.nil?
      allowable_stops = trip.stops
    else
      allowable_stops = trip.stops.reject do |st|
        st["stop_sequence"] < previous_sequence
      end
    end
    first_stop_in_list = allowable_stops.sort_by { |ast| ast["stop_sequence"] }.first
    return([]) if first_stop_in_list.nil?
    bottom_offset = get_offset(first_stop_in_list["arrival_time"])
    schedule_time = parse_mssql_date_time(last_scheduled_time)
    allowable_stops.map do |ast|
      offset = get_offset(ast["arrival_time"]) - bottom_offset #  - (predicted_deviation * 60)
      ast.merge({ 
        "trip_id" => trip.trip_id,
        "last_stop_name" => trip.last_stop_name,
        "scheduled_time" => schedule_time + offset.seconds,
        "calculated_time" => schedule_time + offset.seconds - (predicted_deviation * 60).seconds,
        "vehicle_id" => self.vehicle_id,
        "predicted_deviation" => self.predicted_deviation
      })
    end
  end

  def parse_mssql_date_time(dt_val)
    Time.strptime(dt_val, "%FT%T%:z")
  end

  def get_offset(t_val)
    vals = t_val.split(":").map(&:to_i)
    vals[2] + (vals[1] * 60) + (vals[0] * 60 * 60)
  end

  def self.create_or_update_many(props)
    create_or_update(props)
  end

  def self.create_or_update(params)
    record = nil
    if !params.nil?
      if !params["NewDataSet"].nil?
        if !params["NewDataSet"]["Table"].nil?
          all_records = params["NewDataSet"]["Table"]
          vehicle_data_hash = all_records.inject({}) do |memo, v|
            memo[v['vehicle_id']] = v
            memo
          end
          existing_vehicles = VehiclePosition.by_vehicle_id(:keys => vehicle_data_hash.keys.sort.uniq).docs.inject({}) do |memo, v|
            memo[v['vehicle_id']] = v
            memo
          end
          vehicle_data_hash.each_pair do |k,v|
            evp = existing_vehicles[k]
            if evp.nil?
              VehiclePosition.create(v)
            else
              # Only store the most recent
              if evp.vehicle_position_date_time < v["vehicle_position_date_time"]
                evp.update_attributes(v)
              end
            end
          end
        end
      end
    end
end

def to_param
  vehicle_id
end

end
