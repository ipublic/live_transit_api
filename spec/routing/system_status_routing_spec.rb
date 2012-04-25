require File.join(File.dirname(__FILE__), "..", "spec_helper")
require File.join(File.dirname(__FILE__), "read_only_routing_shared")

describe "routing to system_status" do
  it "system_status" do
    { :get => "/system_status" }.should be_routable
  end
end
