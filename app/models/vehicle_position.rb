class VehiclePosition < CouchRest::Model::Base
  property :vehicle_id, String
  property :latitude, String
  property :longitude, String
  property :speed, String
  property :heading, String
  property :vehicle_position_date_time, String
  property :route_direction, String
  property :route_id, String
  property :trip_id, String
  property :incident_desc, String
  property :last_stop_deviation, String
  property :predicted_deviation, String
  property :previous_stop_id, String
  property :next_stop_id, String
  property :next_scheduled_stop_time, String
  property :incident_date_time, String
  property :last_scheduled_time, String
  property :status_scheduled_time, String

  design do
    view :by_vehicle_id
  end

  def to_xml(options = {}, &block)
    ActiveModel::Serializers::Xml::Serializer.new(self, options).serialize(&block)
  end

  def self.create_or_update(props)
    rec_id = props['vehicle_id']
    record = self.by_vehicle_id.key(rec_id).first
    if record.nil?
      record = self.create!(props)
    else
      record.update_attributes(props)
    end
    record
  end

end
