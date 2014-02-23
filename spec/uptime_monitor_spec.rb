require 'rubygems'
require File.expand_path(File.join(File.dirname(__FILE__), '..', 'lib/uptime_monitor'))

describe Ragios::Plugin::UptimeMonitor do
  before(:each) do
    @u = Ragios::Plugin::UptimeMonitor.new
  end

  it "should read correct browser form" do
    browser = ["firefox", headless: true]
    @u.browser_reader(browser).should == browser
    browser = ["firefox", headless: false]
    @u.browser_reader(browser).should == browser
    browser = ["chrome"]
    @u.browser_reader(browser).should == browser
  end

  it "cannot read incorrect browser form" do
    browser = "firefox"
    expect {@u.browser_reader(browser)}.to raise_error(RuntimeError,"Invalid Browser: #{browser.inspect}")
    browser = [1]
    expect {@u.browser_reader(browser)}.to raise_error(RuntimeError,"Invalid Browser: #{browser.inspect}")
    browser = ["chrome", "string"]
    expect {@u.browser_reader(browser)}.to raise_error(RuntimeError,"Invalid Browser: #{browser.inspect}")
    browser = ["chrome", {:fake=>true}]
    expect {@u.browser_reader(browser)}.to raise_error(RuntimeError,"Invalid Browser: #{browser.inspect}")
  end

  it "evaluates correct browser form" do
  #it only expects corrects browser form
    browser = ["firefox", headless: true]
    result = "firefox"
    @u.browser_eval(browser).should == result
    browser = ["firefox", headless: false]
    @u.browser_eval(browser).should == result
    browser = ["firefox"]
    @u.browser_eval(browser).should == result
  end

  it "reads correct text form" do
    symbol = :page_title
    text =  [text: "Welcome to my site"]
    result = {text: "Welcome to my site"}
    @u.text_reader(symbol, text).should == result
    text =  ["something"=> "Welcome to my site"]
    result = {"something"=> "Welcome to my site"}
    @u.text_reader(symbol, text).should == result
    text =  [{}]
    result = {}
    @u.text_reader(symbol, text).should == result
  end

  it "cannot read incorrect text form" do
    symbol = :page_title
    text = "string"
    expect {@u.text_reader(symbol, text)}.to raise_error(RuntimeError,"Invalid #{symbol} text: #{text.inspect}")
    text = 1
    expect {@u.text_reader(symbol, text)}.to raise_error(RuntimeError,"Invalid #{symbol} text: #{text.inspect}")
    text = {}
    expect {@u.text_reader(symbol, text)}.to raise_error(RuntimeError,"Invalid #{symbol} text: #{text.inspect}")
    text = ["xyz"]
    expect {@u.text_reader(symbol, text)}.to raise_error(RuntimeError,"Invalid #{symbol} text: #{text.first.inspect}")
  end

  it "evaluates and asserts text match" do
    symbol = :page_title
    text = {text: "Welcome to my site"}
    assert_eq_text = "Welcome to my site"
    @u.text?(symbol, text, assert_eq_text).should == true
  end

  it "evaluates and asserts text is included" do
    symbol = :page_title
    text = {includes_text: "to my site"}
    assert_eq_text = "Welcome to my site"
    @u.text?(symbol, text, assert_eq_text).should == true
  end

   it "evaluates and asserts text does not match" do
    symbol = :page_title
    text = {text: "Welcome to my site"}
    assert_eq_text = "Page cannot load"
    @u.text?(symbol, text, assert_eq_text).should == false
  end

  it "evaluates and asserts text is not included" do
    symbol = :page_title
    text = {includes_text: "to my site"}
    assert_eq_text = "Page cannot load"
    @u.text?(symbol, text, assert_eq_text).should == false
  end

  it "cannot evaluate text with unknown symbol" do
    symbol = :page_title
    text = {unknown: "welcome to my site"}
    assert_eq_text = "welcome to my site"
    expect {@u.text?(symbol, text, assert_eq_text)}.to raise_error(RuntimeError,"Could not evaluate #{symbol}: #{text.inspect}")
  end

  it "returns correct text match result when state is passed"

  it "returns correct text match result when state is failed"

  it "returns correct text includes result when state is passed"

  it "returns correct text includes result when state is failed"

  it "can start a headless browser" do
    @u.browser_eval(["", headless: true])
    headless = @u.start_headless
    headless.class.should == Headless
    url = "http://google.com"
    browser = "firefox"
    running_browser = @u.goto(url, browser)
    running_browser.class.should == Watir::Browser
    running_browser.close
    headless.destroy
  end
end