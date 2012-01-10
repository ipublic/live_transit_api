class StopsController < ApplicationController
  before_filter :authenticate_user!
  def index
    @stops = Stop.all.docs

    respond_to do |format|
      format.html { render :json => @stops.as_json(:encoder => LinkedEncoder.new(self)), :content_type => "application/json" }
      format.xml
      format.json { render :json => @stops.as_json(:encoder => LinkedEncoder.new(self)) }
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
      format.html { render :json => @stop.full_json(LinkedEncoder.new(self)), :content_type => "application/json" }
      format.xml
      format.json { render :json => @stop.full_json(LinkedEncoder.new(self)) }
    end
  end

end
