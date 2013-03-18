class TripsController < ApplicationController
  # before_filter :authenticate_user!
  def show
    @trip = Trip.find_by_trip_id(params[:id])

    if @trip
    respond_to do |format|
      format.html {
        self.formats = [:json]
        render :content_type => "application/json"
      }
      format.json
      format.xml
    end
    else
      process_not_found
    end
  end
end
