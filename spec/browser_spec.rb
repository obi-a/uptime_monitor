require 'spec_helper'

describe Hercules::UptimeMonitor::Browser do
  before(:all) do
    url= "http://obi-akubue.org"
    headless = false
    browser_name = "firefox"
    @browser = Hercules::UptimeMonitor::Browser.new(url, browser_name, headless)
  end
  it "can wait until a page element exists" do
    @browser.apply_wait_until?([:title]).should == true
  end
  it "times out if the page element never exists after 30 secs" do
    @browser.apply_wait_until?([{text_field: {id: "abc_dont_exist"}}]).should == false
  end

  it "can apply an action" do
    element = @browser.get_element({text_field: {id: "s"}})
    element.exists?.should ==  true
    @browser.apply_action?(element, {set: "github"}).should ==  true
    element = @browser.get_element({button: {id: "searchsubmit"}})
    element.exists?.should ==  true
    @browser.apply_action?(element, :click).should ==  true
    element = @browser.get_element({link: {text:"Obi Akubue"}})
    element.exists?.should == true
    @browser.apply_action?(element, :click).should ==  true
  end
  it "cannot apply an action with unknown element" do
    element = @browser.get_element({text_field: {id: "abc_dont_exist"}})
    expect{@browser.apply_action?(element, {set: "github"})}.to raise_error(Watir::Exception::UnknownObjectException)
  end
  it "cannot apply an action on element that can't respond to it " do
    element = @browser.get_element({button: {id: "searchsubmit"}})
    element.exists?.should ==  true
    expect{@browser.apply_action?(element, {set: "github"})}.to raise_error(/undefined method `set'/)
  end
  it "cannot apply action in wrong form" do
    element = @browser.get_element({text_field: {id: "s"}})
    element.exists?.should ==  true
    expect{@browser.apply_action?(element, 1)}.to raise_error(Hercules::UptimeMonitor::InvalidAction)
  end

  it "returns true for matching text form" do
   @browser.apply_text?("hello world", {text: "hello world"}).should == true
  end
  it "returns false for non-matching text form" do
   @browser.apply_text?("hello world", {text: "something else"}).should == false
  end
  it "returns true for matching includes_text form" do
   @browser.apply_text?("hello world", {includes_text: "hello"}).should == true
  end
   it "returns false for non-matching includes_text form" do
   @browser.apply_text?("hello world", {includes_text: "something else"}).should == false
  end
  it "cannot match unknown text form" do
    expect{@browser.apply_text?("hello world", {something_else: "something else"})}.to raise_error(Hercules::UptimeMonitor::InvalidText)
  end
  it "can detect correct wait_until form" do
    @browser.is_wait_until?({wait_until_exists?: :anything}).should == true
  end
  it "can detect incorrect wait_until form" do
    @browser.is_wait_until?({something_else: :anything}).should == false
    @browser.is_wait_until?("something_else").should == false
  end
  it "can detect a valid action form" do
    @browser.is_an_action?([set: "admin"]).should == true
    @browser.is_an_action?([:click]).should == true
  end
  it "can detect actions in string form" do
    @browser.is_an_action?(["click"]).should == true
  end
  it "can detect invalid action form" do
    @browser.is_an_action?("something_else").should == false
    @browser.is_an_action?([1]).should == false
  end
  it "can detect valid text form" do
    @browser.is_a_text?([{text: "hello world"}]).should == true
    @browser.is_a_text?([{includes_text: "hello world"}]).should == true
  end
  it "can detect invalid text form" do
    @browser.is_a_text?("something_else").should == false
    @browser.is_a_text?(["something_else"]).should == false
    @browser.is_a_text?([{"something_else"=> :anything}]).should == false
    @browser.is_a_text?([{something_else: :anything}]).should == false
    @browser.is_a_text?([{text: :anything}]).should == false
  end
  it "can apply rest to text form" do
    @browser.apply_rest?("hello world",[{text: "hello world"}]).should == true
  end
  it "can apply rest to action form" do
    element = @browser.get_element({text_field: {id: "s"}})
    element.exists?.should ==  true
    @browser.apply_rest?(element,[{set: "github"}]).should == true
  end
  it "cannot apply rest for unknown form" do
    expect{@browser.apply_rest?(:element,:something_else)}.to raise_error(Hercules::UptimeMonitor::InvalidRest)
  end
  it "returns true when all expressions are true for rest exists" do
    element = @browser.get_element(:title)
    element.exists?.should ==  true
    @browser.rest_exists?(element, [[{text: "Obi Akubue"}],[{includes_text: "Akubue"}]]).should == true
  end
  it "returns false when any expression is false for rest exists" do
    element = @browser.get_element(:title)
    element.exists?.should ==  true
    @browser.rest_exists?(element, [[{text: "Obi Akubue"}],[{includes_text: "something_else"}]]).should == false
  end
  it "returns an element from symbol" do
    element = @browser.get_element(:div)
    element.exists?.should ==  true
  end
  it "returns an element from hash with element and attributes" do
    element = @browser.get_element({a: {href:"http://obi-akubue.org/?feed=rss", id: "rss-link"}})
    element.exists?.should ==  true
  end
  it "returns false for an element doesn't exist" do
    element = @browser.get_element({div: {class: "something_else", id: "something_else"}})
    element.exists?.should ==  false
  end
  it "cannot check an element exists using unusual attributes unless its a css query" do
    element = @browser.get_element({div: {unusual_attribute: "something_else", id: "something_else"}})
    element.exists?.should == false
  end
  it "can check an element exists using unusual attributes with css query" do
    element = @browser.get_element({element: {css: '[data-name="message"]'}})
    element.exists?.should ==  false
    element = @browser.get_element({element: {css: '[something_else="something_else"]'}})
    element.exists?.should ==  false
  end
  it "can use css query to check an element exists" do
    element = @browser.get_element({element: {css: '#rss-link'}})
    element.exists?.should ==  true
  end
  it "can check if an element in string form exists" do
    element = @browser.get_element("title")
    element.exists?.should ==  true
  end
  it "cannot check if an element exists if element has incorrect form" do
    expect{@browser.get_element(1)}.to raise_error(Hercules::UptimeMonitor::InvalidPageElement)
  end
  it "can check if a symbol form page element exists" do
    @browser.page_element_exists?([:title]).should == true
  end
  it "can check if an array form page element exists" do
    @browser.page_element_exists?([{a: {href:"http://obi-akubue.org/?feed=rss", id: "rss-link"}}]).should == true
  end
  it "can check if element exists with rest options in text and/or action form and applies any action form" do
    element = {link: {text:"Obi Akubue"}}, [:click], [text: "Obi Akubue"], [includes_text: "Obi"], [:click]
    @browser.page_element_exists?(element).should == true
    element = {link: {text:"something_else"}}, [:click], [text: "Obi Akubue"], [includes_text: "Obi"], [:click]
    @browser.page_element_exists?(element).should == false
    element = {link: {text:"Obi Akubue"}}, [text: "something_else"], [includes_text: "Obi"], [:click]
    @browser.page_element_exists?(element).should == false
    element = {link: {text:"Obi Akubue"}}, [:click], [text: "Obi Akubue"], [includes_text: "something_else"], [:click]
    @browser.page_element_exists?(element).should == false
  end
  it "cannot check if page_element_exists if first is in wrong form" do
   element = [{div: {unusual_attribute: "something_else", id: "something_else"}}]
   @browser.page_element_exists?(element).should == false
  end
  it "can check if page_element_exists" do
    @browser.exists?([{text_field: {id: "s"}}]).should == true
    @browser.exists?([{wait_until_exists?: [{text_field: {id: "s"}}]}]).should == true
    @browser.exists?([{text_field: {id: "something_else"}}]).should == false
    #returns false if element doesn't exist after waiting for 30 seconds
    @browser.exists?([{wait_until_exists?: [{text_field: {id: "something_else"}}]}]).should == false
  end
  it "cannot check if page_element_exists when in a wrong form" do
    expect{@browser.exists?("something_else")}.to raise_error(Hercules::UptimeMonitor::InvalidPageElementForm)
  end
  it "returns the cdr of an array" do
    @browser.rest((1..5).to_a).should == (2..5).to_a
  end

  after(:all) do
    @browser.close
  end
end
