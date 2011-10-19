class StopsController < ApplicationController
  def index
    @stops = Stop.all.include_docs

    respond_to do |format|
      format.html { render :json => @stops.to_json, :content_type => "application/json" }
      format.xml { render :xml => @stops.docs, :dasherize => false }
      format.json { render :json => @stops.to_json }
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

    respond_to do |format|
      format.html { render :json => @stop, :methods => :stop_times, :content_type => "application/json" }
      format.xml { render :xml => @stop, :methods => :stop_times, :dasherize => false }
      format.json { render :json => @stop, :methods => :stop_times }
    end
  end

end
