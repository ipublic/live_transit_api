require "spec_helper"

GTFS_TEST_DATA_PATH = File.join(
  File.dirname(__FILE__),
  "..",
  "..",
  "test_data",
  "gtfs_test_data.zip"
)

RSpec::Matchers.define :contain_file_entry do |expected|
  match do |actual|
    actual.map(&:name).include?(expected)
  end
end

describe Loaders::Gtfs, "given a file with valid data" do
  subject { Loaders::Gtfs.new(GTFS_TEST_DATA_PATH) }

  its(:source_file) { should eql(GTFS_TEST_DATA_PATH) }
  its(:contained_files) { should have_key("agency.txt") }
  its(:contained_files) { should have_key("calendar.txt") }
  its(:contained_files) { should have_key("calendar_dates.txt") }
  its(:contained_files) { should have_key("routes.txt") }
  its(:contained_files) { should have_key("shapes.txt") }
  its(:contained_files) { should have_key("stops.txt") }
  its(:contained_files) { should have_key("stop_times.txt") }
  its(:contained_files) { should have_key("trips.txt") }
end
