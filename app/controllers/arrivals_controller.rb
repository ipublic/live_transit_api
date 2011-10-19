class ArrivalsController < ApplicationController
  def show
    @arrival = Arrival.find(params[:id])

    respond_to do |format|
      format.html { render :json => @arrival, :content_type => "application/json" }
      format.json { render :json => @arrival }
      format.xml { render :xml => @arrival, :dasherize => false }
    end
  end
end
