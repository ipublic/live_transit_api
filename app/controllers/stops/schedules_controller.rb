class Stops::SchedulesController < ApplicationController
  def show
    @stop_times = StopTime.find_for_stop_and_date(params[:stop_id], params[:id])

    respond_to do |format|
      format.xml { render :xml => @stop_times.to_xml }
      format.json { render :json => @stop_times.to_json }
    end
  end
end
