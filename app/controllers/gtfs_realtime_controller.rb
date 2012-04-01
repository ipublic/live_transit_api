class GtfsRealtimeController < ApplicationController
  before_filter :authenticate_user!
  def show
    @lookup_time, @gtfs_realtime = Gtfs::RealtimeFeed.fetch

    respond_to do |format|
      format.html {
        self.formats = [:txt]
        render :content_type => "text/plain"
      }
      format.txt
    end
  end
end
