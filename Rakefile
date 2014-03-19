# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "uptime_monitor"
  gem.homepage = "http://github.com/obi-a/uptime_monitor"
  gem.license = "MIT"
  gem.summary = %Q{Website uptime monitor plugin for Ragios}
  gem.description = %Q{Website uptime monitor plugin for Ragios}
  gem.email = "obioraakubue@yahoo.com"
  gem.authors = ["obi-a"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

#require 'rcov/rcovtask'
#Rcov::RcovTask.new do |test|
#  test.libs << 'test'
#  test.pattern = 'test/**/test_*.rb'
#  test.verbose = true
#  test.rcov_opts << '--exclude "gems/*"'
#end

task :repl do
  uptime_monitor_file = File.expand_path(File.join(File.dirname(__FILE__), '..', 'uptime_monitor/lib/uptime_monitor'))
  irb = "bundle exec pry -r #{uptime_monitor_file}"
  sh irb
end

task :r => :repl

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "uptime_monitor #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
