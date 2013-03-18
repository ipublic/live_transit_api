class StopTime < ActiveRecord::Base
  belongs_to :trip, :foreign_key => "trip_id", :primary_key => "trip_id"
  belongs_to :stop, :foreign_key => "stop_id", :primary_key => "stop_id"
end
