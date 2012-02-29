class TripUpdatesController < ApplicationController
  before_filter :authenticate_user!
  def index
    @lookup_time, @trip_updates = Gtfs::TripUpdate.all

    respond_to do |format|
      format.html {
        self.formats = [:json]
        render :content_type => "application/json"
      }
      format.json
      format.xml
      format.txt
    end
  end
end
