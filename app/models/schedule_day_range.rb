class ScheduleDayRange
  include CouchRest::Model::Embeddable

  property :start_date, String
  property :end_date, String
  property :day_type, Integer
end
