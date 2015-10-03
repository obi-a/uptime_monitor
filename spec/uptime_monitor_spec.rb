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
=begin
  it "returns true if page element exists" do

    validations = <<-eos
      title
    eos

    monitor = {
      url: "http://obi-akubue.org",
      browser: "firefox headless",
      exists?: validations
    }

    @uptime_monitor.init(monitor)
    @uptime_monitor.test_command?.should == true
    @uptime_monitor.test_result.should == {:results => [["title", "exists_as_expected"]]}
    @uptime_monitor.has_screenshot.should == false
    @uptime_monitor.screenshot_url.should == nil
    @uptime_monitor.success.should == true
    @uptime_monitor.close_browser

=begin
    page_element = [(:title).to_s]
    monitor = {browser: :browser, exists?: page_element, url: :url}
    @uptime_monitor.init(monitor)
    @uptime_monitor.start_browser("http://obi-akubue.org","firefox", headless = true)
    @uptime_monitor.exists([page_element])
    @uptime_monitor.test_result.should == {:results => [[page_element.to_s, "exists_as_expected"]]}
    @uptime_monitor.has_screenshot.should == nil #since no test_command? was run
    @uptime_monitor.screenshot_url.should == nil
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
    if @uptime_monitor.has_screenshot
      !!(/^.*\.png$/.match(@uptime_monitor.screenshot_url)).should == true
    end
    @uptime_monitor.success.should == false
    @uptime_monitor.close_browser
  end
=end
  it "runs a test that passes" do
    monitor = {
      url: "http://obi-akubue.org",
      browser: "firefox headless",
      exists?: "title"
    }
    @uptime_monitor.init(monitor)
    @uptime_monitor.test_command?.should == true
    @uptime_monitor.test_result.should == {:results => [["title", "exists_as_expected"]]}
    @uptime_monitor.has_screenshot.should == false
    @uptime_monitor.screenshot_url.should == nil
    @uptime_monitor.success.should == true
    @uptime_monitor.close_browser
  end
  it "runs a test that fails" do
    monitor = {
      url: "http://obi-akubue.org",
      browser: "firefox headless",
      exists?: 'title.with_text("dont_exist")'
    }
    @uptime_monitor.init(monitor)
    @uptime_monitor.test_command?.should == false
    @uptime_monitor.test_result.should  == {:results => [["title with text \"dont_exist\"", "does_not_exist_as_expected"]]}
    if @uptime_monitor.has_screenshot
      !!(/^.*\.png$/.match(@uptime_monitor.screenshot_url)).should == true
    end
    @uptime_monitor.success.should == false
    @uptime_monitor.close_browser
  end
  it "can disable screenshot capture when a test fails for individual monitors" do
    monitor = {
      url: "http://obi-akubue.org",
      browser: "firefox headless",
      exists?: 'title.with_text("dont_exist")',
      disable_screenshots: true
    }
    @uptime_monitor.init(monitor)
    @uptime_monitor.test_command?.should == false
    @uptime_monitor.has_screenshot.should == false
    @uptime_monitor.screenshot_url.should == nil
    @uptime_monitor.success.should == false
    @uptime_monitor.close_browser
  end
end
