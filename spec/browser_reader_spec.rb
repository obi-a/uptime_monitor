require 'spec_helper'

describe Hercules::UptimeMonitor::BrowserReader do
  before(:each) do
    @browser = "safari"
  end
  it "reads a browser with no headless option" do
    reader = Hercules::UptimeMonitor::BrowserReader.new([@browser])
    reader.browser_name.should == @browser
    reader.headless.should == false
  end
  it "reads a browser with headless false" do
    browser = [@browser, headless: false]
    reader = Hercules::UptimeMonitor::BrowserReader.new(browser)
    reader.browser_name.should == @browser
    reader.headless.should == false
  end
  it "reads a browser with headless true" do
    browser = [@browser, headless: true]
    reader = Hercules::UptimeMonitor::BrowserReader.new(browser)
    reader.browser_name.should == @browser
    reader.headless.should == true
  end
  it "cannot read a browser in wrong form" do
    browser = 1
    expect{Hercules::UptimeMonitor::BrowserReader.new(browser)}.to raise_error(RuntimeError)
    browser = [1]
    expect{Hercules::UptimeMonitor::BrowserReader.new(browser)}.to raise_error(RuntimeError)
    browser = [@browser, 1]
    expect{Hercules::UptimeMonitor::BrowserReader.new(browser)}.to raise_error(RuntimeError)
    browser = [@browser, something: :wrong]
    expect{Hercules::UptimeMonitor::BrowserReader.new(browser)}.to raise_error(RuntimeError)
    browser = [@browser, something: true]
    expect{Hercules::UptimeMonitor::BrowserReader.new(browser)}.to raise_error(RuntimeError)
    browser = [@browser, headless: "true"]
    expect{Hercules::UptimeMonitor::BrowserReader.new(browser)}.to raise_error(RuntimeError)
    browser = [@browser, "headless" => true]
    expect{Hercules::UptimeMonitor::BrowserReader.new(browser)}.to raise_error(RuntimeError)
  end
end
