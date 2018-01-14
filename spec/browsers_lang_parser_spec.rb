require 'spec_helper'

describe Hercules::UptimeMonitor::BrowsersLangParser do
  before(:all) do
    @parser = Hercules::UptimeMonitor::BrowsersLangParser.new
  end
  it "parses valid browser names in the format - [\S]+" do
    @parser.parse("firefox").should == {browser: "firefox", headless: false}
    @parser.parse("   firefox ").should == {browser: "firefox", headless: false}
    @parser.parse("_,0any_non_whitespace").should == {browser: "_,0any_non_whitespace", headless: false}
  end
  it "raises an exception for invalid browser name" do
    expect { @parser.parse("\n") }.to raise_error(/no implicit conversion of nil into String/)
    expect { @parser.parse(" ") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
  end
  it "parses valid specification for headless browser operation" do
    @parser.parse("firefox headless").should == {browser: "firefox", headless: true}
    @parser.parse(" firefox headless ").should == {browser: "firefox", headless: true}
    @parser.parse("   firefox    headless          ").should == {browser: "firefox", headless: true}

    browser = <<-eos
      chrome headless
    eos
    @parser.parse(browser).should == {browser: "chrome", headless: true}

    browser = <<-eos
      chrome

      headless
    eos
    @parser.parse(browser).should == {browser: "chrome", headless: true}
  end
  it "raises an exception for invalid headless assignment" do
    expect { @parser.parse("anybrowser invalid") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
  end
end
