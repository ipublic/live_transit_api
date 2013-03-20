class GtfsRealtimeController < ApplicationController
  # before_filter :authenticate_user!
  def show
    @lookup_time, @gtfs_realtime = Gtfs::RealtimeFeed.fetch

    respond_to do |format|
      format.html {
        self.formats = [:pb]
        send_data(@gtfs_realtime.binary_feed, :file_name => "gtfs_realtime.pb", :content_type => "application/x-protobuf", :disposition => "inline")
      }
      format.txt
    end
  end
end
