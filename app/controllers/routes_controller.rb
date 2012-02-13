class RoutesController < ApplicationController
  before_filter :authenticate_user!
  def index
    @routes = Route.all(:include_docs => true).docs

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
    @route = Route.find_by_route_id(params[:id]) 

    if @route
    respond_to do |format|
      format.html {
        self.formats = [:json]
        render :content_type => "application/json"
      }
      format.json
      format.xml
      format.geojson { render :json => @route.to_geojson }
    end
    else
      process_not_found
    end
  end
end
