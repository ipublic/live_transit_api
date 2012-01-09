class TripsController < ApplicationController
  def show
    @trip = Trip.by_trip_id(:key => params[:id]).first

    respond_to do |format|
      format.html { render :json => @trip, :include => :geometry, :content_type => "application/json" }
      format.xml
      format.json { render :json => @trip, :include => :geometry }
    end
  end
end
