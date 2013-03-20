class ArrivalsController < ApplicationController
  # before_filter :authenticate_user!
  def show
    @limit = params[:limit] || "5"
    @arrival = Arrival.find(params[:id], @limit.to_i)

    if @arrival
    respond_to do |format|
      format.html
      format.json
      format.xml
    end
    else
      process_not_found
    end
  end
end
