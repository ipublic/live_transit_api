#!/usr/bin/ruby

require 'thread'

###################
# CONF            #
###################

# The smallest amount of changed documents before the views are updated
MIN_NUM_OF_CHANGED_DOCS = 10

# URL to the DB on the CouchDB server
URL = "http://localhost:5984"

# Set the minimum pause between calls to the database
PAUSE = 1 # seconds

# One entry for each design document 
# in each database
VIEWS = {"ride_on_api_dev"  => [
  "Stop/_view/all?limit=0",
  "StopTime/_view/all?limit=0",
  "Trip/_view/all?limit=0",
  "ShapePoint/_view/all?limit=0",
  "Route/_view/all?limit=0",
  "Trip/_spatial/by_route_and_date?count=true",
  "StopTime/_spatial/by_stop_and_date?count=true",
  "VehiclePosition/_view/all?limit=0"
]}

###################
# RUNTIME         #
###################

run = true
number_of_changed_docs = VIEWS.inject({}) do |h, (k,v)|
  views_count = v.inject({}) do |vh, vn|
   vh[vn] = 0
   vh
  end
  h[k] = views_count
  h 
end

threads = []

mutex = Mutex.new

# Updates the views
VIEWS.each_pair do |db_name, views|
  views.each do |v_name|
    threads << Thread.new do

      while run do
        number_of_docs = number_of_changed_docs[db_name][v_name]
        if number_of_docs >= MIN_NUM_OF_CHANGED_DOCS

          # Reset the value
          mutex.synchronize {
            number_of_changed_docs[db_name][v_name] = 0
          }

          `curl #{URL}/#{db_name}/_design/#{v_name}`
        end
        # Pause before starting over again
        sleep PAUSE
      end

    end
  end
end

# Receives the update notification from CouchDB
threads << Thread.new do

  while run do

    STDERR << "Waiting for input\n"
    update_call = gets

    # When CouchDB exits the script gets called with
    # a never ending series of nil
    if update_call == nil
      run = false
    else

      # Get the database name out of the call data
      # The data looks something like this:
      # {"type":"updated","db":"DB_NAME"}\n
      update_call =~ /\"db\":\"(\w+)\"/
        database_name = $1
      if number_of_changed_docs.has_key?(database_name)
        mutex.synchronize do

          # Set to 0 if it hasn't been initialized before
          # Add one pending changed document to the list of documents
          # in the DB
          number_of_changed_docs[database_name] = number_of_changed_docs[database_name].inject({}) do |h, (k,v)|
            h[k] = v + 1
            h
          end
        end
      end

    end

  end

end

# Good bye
threads.each {|thr| thr.join}
