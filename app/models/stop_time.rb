class StopTime < CouchRest::Model::Base
  property :stop_id, String
  property :trip_id, String
  property :route_id, String
  property :stop_code, String
  property :stop_name, String
  property :stop_sequence, Integer
  property :stop_geometry, Point
  property :arrival_time, String
  property :departure_time, String

  design do
    view :by_trip_id
    view :for_trip_id, :map => CouchDocLoader["_design/StopTime/views/for_trip_id/map.js"]
    view :by_trip_id_and_stop_id
    view :by_trip_geometry, :map => CouchDocLoader["_design/StopTime/views/by_trip_geometry/map.js"]
    spatial_view :by_stop_and_date, :function => CouchDocLoader["_design/StopTime/spatial/by_stop_and_date.js"]
    list :multiple_trip_stops, :function => CouchDocLoader["_design/StopTime/lists/multiple_trip_stops.js"]
    list :single_trip_stops, :function => CouchDocLoader["_design/StopTime/lists/single_trip_stops.js"]
  end

  attr_writer :last_stop_name, :trip

  def self.find_for_stop_and_date(st_id, date_str)
    results = self.by_stop_and_date(:bbox => calculate_today_bbox(st_id,date_str)).all + self.by_stop_and_date(:bbox => calculate_yesterday_bbox(st_id, date_str)).all
    associated_trips = Trip.by_trip_id.keys(results.map(&:trip_id)).inject({}) do |h, t|
      h[t.trip_id] = t.last_stop_name
      h
    end
    results.each do |r|
      r.last_stop_name = associated_trips[r.trip_id]
    end
    results
  end

  def self.calculate_today_bbox(st_id, date_str)
    date_parts = date_str.split("\s")
    w_day = Date.strptime(date_parts.first, "%Y-%m-%d").wday
    day_val = date_parts[0].gsub("-", "")
    date_key = "#{w_day}.#{day_val}"
    start_t = "0"
    end_t = "235959"
    if !date_parts[1].nil?
      time_parts = date_parts[1].split("-")
      start_t = time_parts[0].gsub(":", "")
      if !time_parts[1].nil?
        end_t = time_parts[1].gsub(":", "")
      end
    end
    start_x = "#{st_id}.#{start_t}"
    end_x = "#{st_id}.#{end_t}"
    [start_x, date_key, end_x, date_key]
  end

  def self.calculate_yesterday_bbox(st_id, date_str)
    date_parts = date_str.split("\s")
    todays_date = Date.strptime(date_parts.first, "%Y-%m-%d")
    w_day = (todays_date - 1).wday
    day_val = (todays_date - 1).strftime("%Y%m%d")
    date_key = "#{w_day}.#{day_val}"
    start_t = "240000"
    end_t = "475959"
    if !date_parts[1].nil?
      time_parts = date_parts[1].split("-")
      first_time_parts = time_parts.first.split(":")
      start_t = ([(first_time_parts.first.to_i + 24).to_s] + first_time_parts[1..-1]).join
      if !time_parts[1].nil?
        end_time_parts = time_parts.last.split(":")
        end_t = ([(end_time_parts.first.to_i + 24).to_s] + end_time_parts[1..-1]).join
      end
    end
    start_x = "#{st_id}.#{start_t}"
    end_x = "#{st_id}.#{end_t}"
    [start_x, date_key, end_x, date_key]
 end

  def to_xml(options = {}, &block)
    ActiveModel::Serializers::Xml::Serializer.new(self, options.merge(:methods => [:last_stop_name, :geometry])).serialize(&block)
  end

  def to_json
    attributes.merge(:last_stop_name => last_stop_name).to_json
  end

  def last_stop_name
    @last_stop_name ||= trip.last_stop_name
  end

  def trip
    @trip ||= Trip.get(self.trip_id)
  end

  def to_geojson
    {
      :type => "Feature",
      :properties => {
        :stop_id => self.stop_id,
        :trip_id => self.trip_id,
        :stop_code => self.stop_code,
        :stop_sequence => self.stop_sequence,
        :type => "Stop",
        :name => "Stop ##{self.stop_sequence}",
        :stop_name => self.stop_name
      },
      :geometry => self.stop_geometry
    }
  end
end
