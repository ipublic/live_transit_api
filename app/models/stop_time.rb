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
    view :for_stop_id, :map => CouchDocLoader["_design/StopTime/views/for_stop_id/map.js"]
    view :by_trip_geometry, :map => CouchDocLoader["_design/StopTime/views/by_trip_geometry/map.js"]
    spatial_view :by_stop_and_date, :function => CouchDocLoader["_design/StopTime/spatial/by_stop_and_date.js"]
    list :multiple_trip_stops, :function => CouchDocLoader["_design/StopTime/lists/multiple_trip_stops.js"]
    list :single_trip_stops, :function => CouchDocLoader["_design/StopTime/lists/single_trip_stops.js"]
    list :single_stop_stops, :function => CouchDocLoader["_design/StopTime/lists/single_stop_stops.js"]
    list :trips_for_stop, :function => CouchDocLoader["_design/StopTime/lists/trips_for_stop.js"]
  end

  attr_writer :last_stop_name, :trip

  def self.find_for_bbox(search_bbox) 
    Rails.cache.fetch("stop_times_#{search_bbox.to_s}") {
      Rails.logger.info "fetching stop_times#{search_bbox.to_s} from couch!"
      StopTime.by_stop_and_date(:bbox => search_bbox).docs }.dup
  end

  def self.stops_for_trips(trip_id_list)
    keys = trip_id_list.uniq.sort
    trip_stops_keys = "stops_for_trip_list_" + Digest::SHA512.hexdigest(keys.to_s)
    Rails.cache.fetch(trip_stops_keys) {
      Rails.logger.info "Fetching stops_for_trip_list_#{keys.to_s} from couchdb!"
      StopTime.multiple_trip_stops(:keys => keys, :view => :for_trip_id).all
    }
  end

  def self.trip_ids_for_stop(stop_id)
    Rails.cache.fetch("trips_for_stop_#{stop_id}") {
      Rails.logger.info "Fetching trips_for_stop_#{stop_id} from couchdb!"
      StopTime.trips_for_stop(:key => stop_id, :view => :for_stop_id).all 
    }
  end

  def self.find_for_stop_and_date(st_id, date_str)
    results = self.by_stop_and_date(:bbox => calculate_day_bbox(st_id,date_str)).all + self.by_stop_and_date(:bbox => calculate_previous_day_bbox(st_id, date_str)).all
    associated_trips = Trip.by_trip_id.keys(results.map(&:trip_id)).inject({}) do |h, t|
      h[t.trip_id] = t.last_stop_name
      h
    end
    results.each do |r|
      r.last_stop_name = associated_trips[r.trip_id]
    end
    results
  end

  def self.date_of_day_bbox(st_id, date_str)
    w_day = Time.strptime(date_str, "%Y-%m-%d").wday
    day_val = date_str.gsub("-", "")
    date_key = "#{w_day}.#{day_val}"
    start_t = "0"
    end_t = "475959"
    start_x = "#{st_id}.#{start_t}"
    end_x = "#{st_id}.#{end_t}"
    [start_x, date_key, end_x, date_key]
  end

  def self.date_after_day_bbox(st_id, date_str)
    todays_date = Time.strptime(date_str, "%Y-%m-%d")
    w_day = (todays_date + 1.day).wday
    day_val = (todays_date + 1.day).strftime("%Y%m%d")
    day_val = date_str.gsub("-", "")
    date_key = "#{w_day}.#{day_val}"
    start_t = "0"
    end_t = "235959"
    start_x = "#{st_id}.#{start_t}"
    end_x = "#{st_id}.#{end_t}"
    [start_x, date_key, end_x, date_key]
  end

  def self.date_before_day_bbox(st_id, date_str)
    todays_date = Time.strptime(date_str, "%Y-%m-%d")
    w_day = (todays_date - 1.day).wday
    day_val = (todays_date - 1.day).strftime("%Y%m%d")
    day_val = date_str.gsub("-", "")
    date_key = "#{w_day}.#{day_val}"
    start_t = "240000"
    end_t = "475959"
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
