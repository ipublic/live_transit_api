require File.join(File.dirname(__FILE__), "..", "spec_helper")

shared_examples_for "read only singular routing for" do |rtype|
  it "#{rtype} /#{rtype}/:id" do
    { :get => "/#{rtype}/7.xml" }.should route_to({ :action => "show", :controller => rtype, :id => "7", :format => "xml"})
    { :get => "/#{rtype}/7.json" }.should route_to({ :action => "show", :controller => rtype, :id => "7", :format => "json"})
  end

  it "does not expose editing of #{rtype}" do
    { :get => "/#{rtype}/7/edit" }.should_not be_routable
  end

  it "does not expose updating of #{rtype}" do
    { :put => "/#{rtype}/7" }.should_not be_routable
  end

  it "does not expose creation of #{rtype}" do
    { :post => "/#{rtype}" }.should_not be_routable
  end

  it "does not expose new #{rtype}" do
    { :get => "/#{rtype}/new" }.should route_to(:controller => rtype, :action => "show", :id => "new")
  end

  it "does not expose deletion of #{rtype}" do
    { :delete => "/#{rtype}/7" }.should_not be_routable
  end
end

shared_examples_for "read only routing for" do |rtype|
  it_should_behave_like "read only singular routing for", rtype

  it "#{rtype} /#{rtype}/:id" do
    { :get => "/#{rtype}.json" }.should route_to({ :action => "index", :controller => rtype, :format => "json"})
    { :get => "/#{rtype}.xml" }.should route_to({ :action => "index", :controller => rtype, :format => "xml"})
  end
end
