class VehiclePositionsController < ApplicationController
  before_filter :authenticate_user!, :except => :create
  def create
    @vehicle_position = VehiclePosition.create_or_update(params)

    respond_to do |format|
      format.xml { render :nothing => true, :status => 202 }
    end
  end

  def index
    @vehicle_positions = VehiclePosition.all.docs

    respond_to do |format|
      format.html {
        self.formats = [:json]
        render :content_type => "application/json"
      }
      format.json
      format.xml
    end
  end

  def show
    @vehicle_position = VehiclePosition.by_vehicle_id(:key => params[:id]).first

    if @vehicle_position
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
