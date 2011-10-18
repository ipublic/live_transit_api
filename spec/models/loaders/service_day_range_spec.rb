require "spec_helper"

describe Loaders::ServiceDayRange, "given:
  - a start_date
  - an end_date
  - a day_type
  - a service_id
" do
  let(:starting_date) { Date.civil(2004,2,29) }
  let(:ending_date) { Date.civil(2005, 1, 3) }

  subject {
    Loaders::ServiceDayRange.new({
      :service_id => 24,
      :day_type => 3,
      :start_date => starting_date,
      :end_date => ending_date
    })
  }

  describe "#remove_exception" do

    it "should only return itself when given an exception for a different day type" do
      mock_exception = mock("ServiceExceptionRecord", { :service_id => 24, :day_type => 5 })
      res = subject.remove_exception(mock_exception).first
      res.service_id.should eql(24)
      res.day_type.should eql(3)
      res.range.should eql((starting_date..ending_date))
    end

    it "should only return itself when given an exception for a different service_id" do
      mock_exception = mock("ServiceExceptionRecord", { :service_id => 4, :day_type => 3 })
      res = subject.remove_exception(mock_exception).first
      res.service_id.should eql(24)
      res.day_type.should eql(3)
      res.range.should eql((starting_date..ending_date))
    end

    it "should only return itself, but one day shorter, with a matching exception that falls on the last day" do
      mock_exception = mock("ServiceExceptionRecord", { 
        :service_id => 24,
        :day_type => 3,
        :date => ending_date
      })
      res = subject.remove_exception(mock_exception).first
      res.service_id.should eql(24)
      res.day_type.should eql(3)
      res.range.should eql((starting_date..(ending_date - 1)))
    end

    it "should only return itself, but one day later, with a matching exception that falls on the first" do
      mock_exception = mock("ServiceExceptionRecord", { 
        :service_id => 24,
        :day_type => 3,
        :date => starting_date
      })
      res = subject.remove_exception(mock_exception).first
      res.service_id.should eql(24)
      res.day_type.should eql(3)
      res.range.should eql(((starting_date + 1)..ending_date))
    end

    it "should return two properly split ranges, with a matching exception that falls in the middle" do
      mock_exception = mock("ServiceExceptionRecord", { 
        :service_id => 24,
        :day_type => 3,
        :date => ending_date - 4
      })
      res1, res2 = subject.remove_exception(mock_exception)
      res1.service_id.should eql(24)
      res1.day_type.should eql(3)
      res1.range.should eql((starting_date..(ending_date - 5)))
      res2.service_id.should eql(24)
      res2.day_type.should eql(3)
      res2.range.should eql(((ending_date - 3)..ending_date))
    end
  end

end
