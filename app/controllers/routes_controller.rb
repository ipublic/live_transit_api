class RoutesController < ApplicationController
  def index
    @routes = Route.all.docs

    respond_to do |format|
      format.html { render :json => @routes.to_json, :content_type => "application/json" }
      format.json { render :json => @routes.to_json }
      format.xml { render :xml => @routes.to_xml }
    end
  end

  def show
    @route = Route.find_by_short_name(params[:id])

    respond_to do |format|
      format.html { render :json => @route.full_json, :content_type => "application/json" }
      format.xml { render :xml => @route, :methods => [:trips, :shapes] }
      format.json { render :json => @route.full_json }
      format.geojson { render :json => @route.to_geojson }
    end
  end
end
