class GtfsTripUpdatesController < ApplicationController
  before_filter :authenticate_user!
  def show
    @lookup_time, @gtfs_trip_updates = Gtfs::TripUpdateFeed.fetch

    respond_to do |format|
      format.html {
        self.formats = [:pb]
        send_data(@gtfs_trip_updates.binary_feed, :file_name => "gtfs_realtime.pb", :content_type => "application/x-protobuf", :disposition => "inline")
      }
      format.txt
    end
  end
end
