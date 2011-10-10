require File.join(File.dirname(__FILE__), "..", "spec_helper")
require File.join(File.dirname(__FILE__), "read_only_routing_shared")

describe "routing to stops_schedules" do

  it "exposes a list of stop schedules" do
    { :get => "/stops/7/schedules/2010-11-05%2002:24.json" }.should route_to(
      :controller => "Stops/schedules",
      :action => "show",
      :format => "json",
      :stop_id => "7",
      :id => "2010-11-05 02:24"
    )
    { :get => "/stops/7/schedules/2010-11-05%2002:24.xml" }.should route_to(
      :controller => "Stops/schedules",
      :action => "show",
      :format => "xml",
      :stop_id => "7",
      :id => "2010-11-05 02:24"
    )
  end
end
