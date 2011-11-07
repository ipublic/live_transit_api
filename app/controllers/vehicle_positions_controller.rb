class VehiclePositionsController < ApplicationController
  def create
    @vehicle_postion = VehiclePosition.create_or_update(params[:NewDataSet][:Table])

    respond_to do |format|
      format.html { render :json => @vehicle_position, :content_type => "application/json" }
      format.xml { render :xml => @vehicle_position, :dasherize => false }
      format.json { render :json => @vehicle_position }
    end

  end
end
