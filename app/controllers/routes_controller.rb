class RoutesController < ApplicationController
  def index
    @routes = Route.all.docs

    respond_to do |format|
      format.xml { render :xml => @routes.to_xml }
      format.json { render :json => @routes.to_json }
    end
  end

  def show
    @route = Route.find_by_short_name(params[:id])

    respond_to do |format|
      format.xml { render :xml => @route, :methods => [:trips, :shapes] }
      format.json { render :json => @route.full_json }
      format.geojson { render :json => @route.to_geojson }
    end
  end
end
