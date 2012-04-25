require "spec_helper"

describe LiveTransitSystemStatus, "with no faux vehicle positions available" do
  let(:fake_time) { Time.mktime(2012, 2, 24, 15, 3, 23) }
  let(:fake_vehicles) { mock("Docs", :docs => [] ) }
  let(:expected_vehicle_reporting_buckets) {
    [
["Within 1 Minute", 0],
["1-2 Minutes", 0],
["2-3 Minutes", 0],
["3-4 Minutes", 0],
["4-5 Minutes", 0],
["5 Minutes - Last Hour", 0]
  ]
  }

  subject { 
    Time.stub(:now).and_return(fake_time)
    VehiclePosition.stub(:all).and_return(fake_vehicles)
    LiveTransitSystemStatus.new
  }

  its(:report_time) { should eql(fake_time) }
  its(:vehicle_reporting_buckets) { should eql(expected_vehicle_reporting_buckets) }

end

describe LiveTransitSystemStatus, "with some faux vehicle positions available" do
  let(:fake_time) { Time.mktime(2012, 2, 24, 15, 3, 23) }
  let(:fake_vehicles) { mock("Docs", :docs => [
    mock("VehiclePosition", :latest_report_time => fake_time - 30.seconds),
    mock("VehiclePosition", :latest_report_time => fake_time - 8.minutes),
    mock("VehiclePosition", :latest_report_time => fake_time - 150.seconds),
    mock("VehiclePosition", :latest_report_time => fake_time - 180.seconds),
    mock("VehiclePosition", :latest_report_time => fake_time - 121.seconds),
    mock("VehiclePosition", :latest_report_time => fake_time - 60.seconds)
  ] ) }
  let(:expected_vehicle_reporting_buckets) {
    [
["Within 1 Minute", 2],
["1-2 Minutes", 0],
["2-3 Minutes", 3],
["3-4 Minutes", 0],
["4-5 Minutes", 0],
["5 Minutes - Last Hour", 1]
  ]
  }

  subject { 
    Time.stub(:now).and_return(fake_time)
    VehiclePosition.stub(:all).and_return(fake_vehicles)
    LiveTransitSystemStatus.new
  }

  its(:report_time) { should eql(fake_time) }
  its(:vehicle_reporting_buckets) { should eql(expected_vehicle_reporting_buckets) }

end
