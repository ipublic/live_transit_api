class TripsController < ApplicationController
  def show
    @trip = Trip.by_trip_id(:key => params[:id]).first

    respond_to do |format|
      format.xml { render :xml => @trip, :include => :geometry }
      format.json { render :json => @trip, :include => :geometry }
    end
  end
end
