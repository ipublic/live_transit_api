class ArrivalsController < ApplicationController
  before_filter :authenticate_user!
  def show
    @arrival = Arrival.find(params[:id])

    if @arrival
    respond_to do |format|
      format.html {
        self.formats = [:json]
        render :content_type => "application/json"
      }
      format.json
      format.xml
    end
    else
      process_not_found
    end
  end
end
