class RoutesController < ApplicationController
  before_filter :authenticate_user!
  def index
    @routes = Route.all.docs

    respond_to do |format|
      format.html { render :json => @routes.as_json(:encoder => LinkedEncoder.new(self)), :content_type => "application/json" }
      format.json { render :json => @routes.as_json(:encoder => LinkedEncoder.new(self)) }
      format.xml
    end
  end

  def show
    @route = Route.find_by_route_id(params[:id])

    respond_to do |format|
      format.html { render :json => @route.full_json(LinkedEncoder.new(self)), :content_type => "application/json" }
      format.json { render :json => @route.full_json(LinkedEncoder.new(self)) }
      format.xml
      format.geojson { render :json => @route.to_geojson }
    end
  end
end
