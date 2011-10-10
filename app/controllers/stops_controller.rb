class StopsController < ApplicationController
  def index
    @stops = Stop.all.include_docs

    respond_to do |format|
      format.xml { render :xml => @stops.docs }
      format.json { render :json => @stops }
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
      format.xml { render :xml => @stop }
      format.json { render :json => @stop }
    end
  end

end
