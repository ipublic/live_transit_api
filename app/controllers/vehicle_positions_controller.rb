class VehiclePositionsController < ApplicationController
  def create
    @vehicle_position = VehiclePosition.create_or_update(params[:NewDataSet][:Table])

    respond_to do |format|
      format.html { render :json => @vehicle_position, :content_type => "application/json", :status => :ok }
      format.xml { render :xml => @vehicle_position.to_xml({:dasherize => false}), :status => :ok }
      format.json { render :json => @vehicle_position, :status => :ok }
    end
  end
end
