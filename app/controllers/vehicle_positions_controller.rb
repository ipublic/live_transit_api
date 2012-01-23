class VehiclePositionsController < ApplicationController
  def create
    @vehicle_position = VehiclePosition.create_or_update(params)

    respond_to do |format|
      format.xml { render :nothing => true, :status => 202 }
    end
  end
end
