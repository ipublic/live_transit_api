class TripsController < ApplicationController
  before_filter :authenticate_user!
  def show
    @trip = Trip.by_trip_id(:key => params[:id]).first

    respond_to do |format|
      format.html { render :json => @trip.full_json(LinkedEncoder.new(self)), :content_type => "application/json" }
      format.json { render :json => @trip.full_json(LinkedEncoder.new(self)) }
      format.xml
    end
  end
end
