require 'spec_helper'

describe Loaders::ServiceRecord, "given:
  - a service_id
  - a start_date
  - an end_date
  - monday, tuesday, wednesday, thursday, friday, saturday, sunday with values of:
    1,0,0,1,0,0,0
" do
  let(:common_service_props) {
    {
      :service_id => 24,
      :start_date => Date.civil(2004, 03, 24),
      :end_date => Date.civil(2005, 10, 1)
    }
  }

  subject {
    Loaders::ServiceRecord.new(
      common_service_props.merge({
      :monday => 1,
      :tuesday => 0,
      :wednesday => 0,
      :thursday => 1,
      :friday => 0,
      :saturday => 0,
      :sunday => 0
    }))
  }


  its(:service_ranges) { should include(common_service_props.merge({:day_type => 1})) }
  its(:service_ranges) { should include(common_service_props.merge({:day_type => 4})) }

end
