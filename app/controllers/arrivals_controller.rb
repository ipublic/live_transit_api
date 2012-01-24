class ArrivalsController < ApplicationController
  before_filter :authenticate_user!
  def show
    @arrival = Arrival.find(params[:id])

    respond_to do |format|
      format.html {
        self.formats = [:json]
        render :content_type => "application/json"
      }
      format.json
      format.xml { render :xml => @arrival, :dasherize => false }
    end
  end
end
