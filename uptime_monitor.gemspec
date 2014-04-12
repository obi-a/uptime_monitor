# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-
# stub: uptime_monitor 0.0.5 ruby lib

Gem::Specification.new do |s|
  s.name = "uptime_monitor"
  s.version = "0.0.5"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.require_paths = ["lib"]
  s.authors = ["obi-a"]
  s.date = "2014-04-12"
  s.description = "A Ragios plugin that uses a real web browser to monitor transactions on a website for availability"
  s.email = "obioraakubue@yahoo.com"
  s.extra_rdoc_files = [
    "LICENSE",
    "README.md"
  ]
  s.files = [
    ".document",
    ".travis.yml",
    "Gemfile",
    "Gemfile.lock",
    "LICENSE",
    "README.md",
    "Rakefile",
    "VERSION",
    "lib/uptime_monitor.rb",
    "lib/uptime_monitor/browser.rb",
    "lib/uptime_monitor/browser_reader.rb",
    "lib/uptime_monitor/uptime_monitor.rb",
    "spec/browser_reader_spec.rb",
    "spec/browser_spec.rb",
    "spec/spec_helper.rb",
    "spec/uptime_monitor_spec.rb",
    "uptime_monitor.gemspec"
  ]
  s.homepage = "http://github.com/obi-a/uptime_monitor"
  s.licenses = ["MIT"]
  s.rubygems_version = "2.2.2"
  s.summary = "Real browser website uptime monitoring plugin for Ragios"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<headless>, [">= 0"])
      s.add_runtime_dependency(%q<watir-webdriver>, [">= 0"])
      s.add_runtime_dependency(%q<watir-webdriver-performance>, [">= 0"])
      s.add_runtime_dependency(%q<activesupport>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_development_dependency(%q<bundler>, ["~> 1.0"])
      s.add_development_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_development_dependency(%q<pry>, [">= 0"])
    else
      s.add_dependency(%q<headless>, [">= 0"])
      s.add_dependency(%q<watir-webdriver>, [">= 0"])
      s.add_dependency(%q<watir-webdriver-performance>, [">= 0"])
      s.add_dependency(%q<activesupport>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rdoc>, ["~> 3.12"])
      s.add_dependency(%q<bundler>, ["~> 1.0"])
      s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
      s.add_dependency(%q<pry>, [">= 0"])
    end
  else
    s.add_dependency(%q<headless>, [">= 0"])
    s.add_dependency(%q<watir-webdriver>, [">= 0"])
    s.add_dependency(%q<watir-webdriver-performance>, [">= 0"])
    s.add_dependency(%q<activesupport>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rdoc>, ["~> 3.12"])
    s.add_dependency(%q<bundler>, ["~> 1.0"])
    s.add_dependency(%q<jeweler>, ["~> 1.8.7"])
    s.add_dependency(%q<pry>, [">= 0"])
  end
end

