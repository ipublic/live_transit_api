require File.join(File.dirname(__FILE__), "..", "spec_helper")
require File.join(File.dirname(__FILE__), "read_only_routing_shared")

describe "routing to stops" do
  it_should_behave_like "read only routing for", "stops"
end
