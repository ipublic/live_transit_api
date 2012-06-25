class SignsController < ApplicationController
  before_filter :authenticate_user!
  def show
    limit = params[:limit].blank? ? 5 : params[:limit].to_i
    @sign = Oba::ArrivalsResource.find(params[:id], limit)

    if @sign
    respond_to do |format|
      format.html
    end
    else
      process_not_found
    end
  end
end
