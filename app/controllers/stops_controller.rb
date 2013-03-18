class StopsController < ApplicationController
  # before_filter :authenticate_user!
  def index
    @stops = Rails.cache.fetch("all_stops") { 
      Rails.logger.info "Looking up all stops"
      Stop.all(:include_docs => true).docs }

    respond_to do |format|
      format.html {
        self.formats = [:json]
        render :content_type => "application/json"
      }
      format.xml
      format.json 
      format.geojson do 
        render({ :json => ({ 
          :type => "FeatureCollection",
          :features => @stops.map(&:as_geojson)
        }).to_json
        })
      end
    end
  end

  def show
    @stop = Stop.find_by_stop_code(params[:id])

    if @stop
    respond_to do |format|
      format.html {
        self.formats = [:json]
        render :content_type => "application/json"
      }
      format.xml
      format.json
    end
    else
      process_not_found
    end
  end

end
