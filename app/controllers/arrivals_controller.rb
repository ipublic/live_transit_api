class ArrivalsController < ApplicationController
  def show
    @arrival = Arrival.find(params[:id])

    respond_to do |format|
      format.xml { render :xml => @arrival }
      format.json { render :json => @arrival }
    end
  end
end
