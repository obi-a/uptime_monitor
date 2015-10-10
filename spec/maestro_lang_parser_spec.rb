require 'spec_helper'

describe Hercules::UptimeMonitor::MaestroLangParser do
  before(:all) do
    @parser = Hercules::UptimeMonitor::MaestroLangParser.new
  end
  it "it returns correct s expression for html elements" do
    validations = <<-eos
      h1
      div
      anything
    eos
    @parser.parse(validations).should == [[:h1], [:div], [:anything]]
  end
  it "it returns correct description for html elements" do
    validations = <<-eos
      h1
      div
      anything
    eos
    @parser.parse(validations, description = true).should == ["h1", "div", "anything"]
  end
  it "raises exceptions for incorrect html element format" do
    expect{ @parser.parse("1hi") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
    expect{ @parser.parse(" 1hi ") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
  end
  it "returns the correct s expression for element validation" do
    validations = <<-eos
      div.where( class: "box_content")
      div.where( id: "test", class: "test-section" )
      link.where ( href: "https://www.southmunn.com/aboutus")
      text_field.where(id: "search")
    eos
    @parser.parse(validations).should == [
      [div: {class: "box_content"}],
      [div: {id:"test", class: "test-section"}],
      [link: {href: "https://www.southmunn.com/aboutus"}],
      [text_field: {id: "search"}],
    ]
  end
  it "returns the correct description for element validation" do
    validations = <<-eos
      div.where(class: "box_content")
      div.where(id: "test", class: "test-section" )
      link.where(href: "https://www.southmunn.com/aboutus")
      text_field.where(id:"search")
    eos
    @parser.parse(validations, description = true).should == [
      'div, with class equals to "box_content"',
      'div, with id equals to "test", class equals to "test-section"',
      'link, with href equals to "https://www.southmunn.com/aboutus"',
      'text_field, with id equals to "search"'
    ]
  end
  it "returns the correct s expression for text validations" do
    validations = <<-eos
      title.with_text( "Welcome to my site" )
      title.includes_text ( "Welcome")
      div.where(class: "box_content").includes_text( "SouthMunn is a Website")
      title.includes_text("ruby").includes_text ("Search Results")
    eos
    @parser.parse(validations).should == [
      [:title, [text: "Welcome to my site"]],
      [:title, [includes_text: "Welcome"]],
      [{div: {class: "box_content"}}, [includes_text: "SouthMunn is a Website"]],
      [:title, [includes_text: "ruby"], [includes_text: "Search Results"]]
    ]
  end
  it "returns the correct description for text validations" do
    validations = <<-eos
      title.with_text("Welcome to my site")
      title.includes_text("Welcome")
      div.where(class: "box_content").includes_text("SouthMunn is a Website")
      title.includes_text("ruby").includes_text("Search Results")
    eos
    @parser.parse(validations, description = true).should == [
      'title, with text "Welcome to my site"',
      'title, includes text "Welcome"',
      'div, with class equals to "box_content", includes text "SouthMunn is a Website"',
      'title, includes text "ruby", includes text "Search Results"'
    ]
  end
  it "returns the correct s expression for actions" do
    validations = <<-eos
      text_area.where(name:"longtext").set("In a world...")
      select_list.where(name: "mydropdown").select("Old Cheese")
      radio.where(name: "group1", value: "Milk").click
      button.where(value: "Add to Cart").click
      button.click
    eos
    @parser.parse(validations).should == [
      [{text_area: {name: "longtext"}}, [set: "In a world..."]],
      [{select_list: {name: "mydropdown"}},[select: "Old Cheese"]],
      [{radio: {name: "group1", value: "Milk"}}, [:click]],
      [{button: {value: "Add to Cart"}}, [:click]],
      [:button, [:click]]
    ]
  end
  it "returns the correct description for validations within actions" do
    validations = <<-eos
      text_area.where(name:"longtext").set("In a world...")
      select_list.where(name: "mydropdown").select("Old Cheese")
      radio.where(name: "group1", value: "Milk").click
      button.where(value: "Add to Cart").click
      button.click
    eos
    @parser.parse(validations, description = true).should == [
      'text_area, with name equals to "longtext"',
      'select_list, with name equals to "mydropdown"',
      'radio, with name equals to "group1", value equals to "Milk"',
      'button, with value equals to "Add to Cart"',
      'button'
    ]
  end
  it "returns the correct s expression for waiting" do
    validations = <<-eos
      wait_for title.with_text("Obi Akubue")
      wait_for title.includes_text("ruby").includes_text("Search Results")
      wait_for text_field.where(id: "s").set("ruby")
      wait_for div.where( class: "box_content")
    eos
    @parser.parse(validations).should == [
      [wait_until_exists?: [:title,[text: "Obi Akubue"]]],
      [wait_until_exists?: [:title, [includes_text: "ruby"], [includes_text: "Search Results"]]],
      [wait_until_exists?: [{text_field: {id: "s"}}, [set: "ruby"]]],
      [wait_until_exists?: [div: {class: "box_content"}]]
    ]
  end
  it "returns the correct description for waiting" do
    validations = <<-eos
      wait_for title.with_text("Obi Akubue")
      wait_for title.includes_text("ruby").includes_text("Search Results")
      wait_for text_field.where(id: "s").set("ruby")
      wait_for div.where( class: "box_content")
    eos
    @parser.parse(validations, description = true).should == [
      'waited, title, with text "Obi Akubue"',
      'waited, title, includes text "ruby", includes text "Search Results"',
      'waited, text_field, with id equals to "s"',
      'waited, div, with class equals to "box_content"'
    ]
  end
  it "detects syntax errors" do
    expect{ @parser.parse(".anything") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
    expect { @parser.parse("h1.where") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
    expect { @parser.parse("anything.anything") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
    expect { @parser.parse("div.where(\"test\" => \"test\")") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
    expect { @parser.parse("div.where(:test => \"test\")") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
    expect { @parser.parse("title.with_text(Welcome to my site\")") }.to raise_error(Hercules::UptimeMonitor::ParserSyntaxError)
  end
end


