class SystemStatusController < ApplicationController
  before_filter :authenticate_user!
  def show
    @system_status = LiveTransitSystemStatus.new

    respond_to do |format|
      format.html
    end
  end
end
