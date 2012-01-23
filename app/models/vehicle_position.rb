class VehiclePosition < CouchRest::Model::Base
  property :vehicle_id, String
  property :latitude, String
  property :longitude, String
  property :speed, String
  property :heading, String
  property :vehicle_position_date_time, String
  property :trip_id, String
  property :last_stop_deviation, String
  property :predicted_deviation, String
  property :previous_sequence, Integer
  property :next_sequence, Integer

  design do
    view :by_vehicle_id
  end

  def to_xml(options = {}, &block)
    ActiveModel::Serializers::Xml::Serializer.new(self, options).serialize(&block)
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
