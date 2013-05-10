# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130409213611) do

  create_table "agencies", :force => true do |t|
    t.string "agency_id"
    t.string "agency_name",     :limit => 512,  :null => false
    t.string "agency_url",      :limit => 1024, :null => false
    t.string "agency_timezone",                 :null => false
    t.string "agency_lang"
    t.string "agency_phone"
    t.string "agency_fare_url", :limit => 1024
  end

  create_table "features_stops", :force => true do |t|
    t.string   "stop_id",                                                                                        :null => false
    t.spatial  "stop_latlon",         :limit => {:srid=>4326, :type=>"point", :geographic=>true},                :null => false
    t.string   "stop_code"
    t.string   "stop_name",                                                                                      :null => false
    t.text     "stop_desc"
    t.string   "zone_id"
    t.string   "stop_url"
    t.integer  "location_type",                                                                   :default => 0
    t.string   "parent_station"
    t.string   "stop_timezone"
    t.integer  "wheelchair_boarding",                                                             :default => 0
    t.datetime "created_at",                                                                                     :null => false
    t.datetime "updated_at",                                                                                     :null => false
  end

  create_table "routes", :force => true do |t|
    t.string  "route_id",                         :null => false
    t.string  "agency_id"
    t.string  "route_short_name",                 :null => false
    t.string  "route_long_name",  :limit => 1024, :null => false
    t.text    "route_desc"
    t.integer "route_type",                       :null => false
    t.string  "route_url",        :limit => 1024
    t.string  "route_color"
    t.string  "route_text_color"
  end

  create_table "shape_points", :force => true do |t|
    t.string  "shape_id",            :null => false
    t.float   "shape_pt_lat",        :null => false
    t.float   "shape_pt_lon",        :null => false
    t.integer "shape_pt_sequence",   :null => false
    t.float   "shape_dist_traveled"
  end

  create_table "stop_time_events", :force => true do |t|
    t.integer "stop_time_id",   :null => false
    t.string  "stop_id",        :null => false
    t.integer "arrival_time"
    t.integer "departure_time"
  end

  create_table "stop_time_services", :id => false, :force => true do |t|
    t.integer "stop_time_id",   :null => false
    t.string  "stop_id",        :null => false
    t.integer "service_id",     :null => false
    t.integer "arrival_time"
    t.integer "departure_time"
  end

  create_table "stop_times", :force => true do |t|
    t.string  "stop_id",                            :null => false
    t.string  "trip_id",                            :null => false
    t.integer "stop_sequence",                      :null => false
    t.integer "arrival_time",                       :null => false
    t.integer "departure_time",                     :null => false
    t.string  "stop_headsign",       :limit => 512
    t.integer "pickup_type"
    t.integer "drop_off_type"
    t.float   "shape_dist_traveled"
  end

  create_table "stops", :force => true do |t|
    t.string  "stop_id",                             :null => false
    t.string  "stop_code"
    t.string  "stop_name",           :limit => 512,  :null => false
    t.text    "stop_desc"
    t.float   "stop_lat",                            :null => false
    t.float   "stop_lon",                            :null => false
    t.string  "zone_id"
    t.string  "stop_url",            :limit => 1024
    t.integer "location_type"
    t.string  "parent_station"
    t.string  "stop_timezone"
    t.integer "wheelchair_boarding"
  end

  create_table "trip_days", :force => true do |t|
    t.integer "service_id", :null => false
    t.integer "day",        :null => false
  end

  create_table "trips", :force => true do |t|
    t.string  "trip_id",                           :null => false
    t.string  "route_id",                          :null => false
    t.integer "service_id",                        :null => false
    t.string  "trip_headsign",      :limit => 512
    t.string  "trip_short_name",    :limit => 512
    t.integer "direction_id"
    t.string  "block_id",                          :null => false
    t.string  "shape_id",                          :null => false
    t.integer "last_stop_sequence",                :null => false
  end

end
