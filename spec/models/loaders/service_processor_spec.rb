require "spec_helper"

SERVICE_DATA = <<-SERVICE_HEREDOC
service_id,monday,tuesday,wednesday,thursday,friday,saturday,sunday,start_date,end_date
1,1,1,1,1,1,0,0,20110501,20110903
2,0,0,0,0,0,1,0,20110501,20110903
3,0,0,0,0,0,0,1,20110501,20110903
6,0,0,0,0,0,0,0,20110501,20110903
SERVICE_HEREDOC

EXCEPTION_DATA = <<-EXCEPTION_HEREDOC
service_id,date,exception_type
3,20110530,1
1,20110530,2
2,20110704,1
1,20110704,2
3,20110905,1
1,20110905,2
EXCEPTION_HEREDOC

describe Loaders::ServiceProcessor, "

given service data of:
#{SERVICE_DATA}
and exception data of:
#{EXCEPTION_DATA}

" do
  subject {
    Loaders::ServiceProcessor.new(
      SERVICE_DATA,
      EXCEPTION_DATA
    )
  }

  it { should have(4).service_records }
  it { should have(6).exception_records }
  its(:keyed_services) { should have(3).keys }

end
