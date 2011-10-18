class StopsController < ApplicationController
  def index
    @stops = Stop.all.include_docs

    respond_to do |format|
      format.xml { render :xml => @stops.docs }
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
      format.xml { render :xml => @stop, :methods => :stop_times }
      format.json { render :json => @stop, :methods => :stop_times }
    end
  end

end
