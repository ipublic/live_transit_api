class Stop < ActiveRecord::Base
  has_many :stop_times, :foreign_key => "stop_id", :primary_key => "stop_id"

  def geometry
    {
      :type => "Point",
      :coordinates => [stop_lon, stop_lat]
    }
  end
end
