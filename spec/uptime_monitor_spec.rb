require 'spec_helper'

describe Ragios::Plugin::UptimeMonitor do
  before(:each) do
    @uptime_monitor = Ragios::Plugin::UptimeMonitor.new
  end
  it "sets the correct test result for success" do
    @uptime_monitor.result!("page_element", state = true)
    @uptime_monitor.test_result.should == {:results=>[["page_element", "exists_as_expected"]]}
    @uptime_monitor.success.should == nil #since no test_command? was run
  end
  it "sets the correct test result for failure" do
    @uptime_monitor.result!(:page_element, state = false)
    @uptime_monitor.test_result.should == {:results=>[[:page_element, "does_not_exist_as_expected"]]}
    @uptime_monitor.success.should == false
  end
  it "sets test_result as failure if any validation fails" do
    @uptime_monitor.result!(:page_element, state = false)
    @uptime_monitor.result!(:page_element, state = true)
    @uptime_monitor.result!(:page_element, state = true)
    @uptime_monitor.result!(:page_element, state = true)
    @uptime_monitor.success.should == false
  end
  it "must include a url" do
    monitor = {exists?: :exists, browser: :browser}
    expect{@uptime_monitor.init(monitor)}.to raise_error(Hercules::UptimeMonitor::NoUrlProvided)
  end
  it "must include a browser" do
    monitor = {exists?: :exists, url: :url}
    expect{@uptime_monitor.init(monitor)}.to raise_error(Hercules::UptimeMonitor::NoBrowserProvided)
  end
  it "must include a validation" do
    monitor = {browser: :browser, url: :url}
    expect{@uptime_monitor.init(monitor)}.to raise_error(Hercules::UptimeMonitor::NoValidationProvided)
  end
  it "returns true if page element exists" do
    monitor = {browser: :browser, exists?: :exists, url: :url}
    @uptime_monitor.init(monitor)
    @uptime_monitor.start_browser("http://obi-akubue.org","firefox", headless = true)
    page_element = [:title]
    @uptime_monitor.exists([page_element])
    @uptime_monitor.test_result.should == {:results => [[page_element, "exists_as_expected"]]}
    @uptime_monitor.success.should == nil #since no test_command? was run
    @uptime_monitor.close_browser
  end
  it "returns false if page element don't exists" do
    monitor = {browser: :browser, exists?: :exists, url: :url}
    @uptime_monitor.init(monitor)
    @uptime_monitor.start_browser("http://obi-akubue.org","firefox", headless = true)
    page_element = [:title, [text: "dont_exist"]]
    @uptime_monitor.exists([page_element])
    @uptime_monitor.test_result.should == {:results => [[page_element, "does_not_exist_as_expected"]]}
    @uptime_monitor.success.should == false
    @uptime_monitor.close_browser
  end
  it "runs a test that passes" do
    page_element = [:title]
    monitor = {url: "http://obi-akubue.org",
                browser: ["firefox", headless: true],
                exists?: [page_element]
              }
    @uptime_monitor.init(monitor)
    @uptime_monitor.test_command?.should == true
    @uptime_monitor.test_result.should == {:results => [[page_element, "exists_as_expected"]]}
  end
  it "runs a test that fails" do
    page_element = [:title, [text: "dont_exist"]]
    monitor = {url: "http://obi-akubue.org",
                browser: ["firefox", headless: true],
                exists?: [page_element]
              }
    @uptime_monitor.init(monitor)
    @uptime_monitor.test_command?.should == false
    @uptime_monitor.test_result.should  include(:results => [[page_element, "does_not_exist_as_expected"]])
  end
end
