# require 'headless'
require 'watir'
require 'watir-webdriver-performance'
require 'ostruct'
require 'aws/s3'

def require_all(path)
  Dir.glob(File.dirname(__FILE__) + path + '/*.rb') do |file|
    require File.dirname(__FILE__)  + path + '/' + File.basename(file, File.extname(file))
  end
end

def setup_screenshot_dir
  FileUtils.mkdir_p RAGIOS_HERCULES_SCREENSHOT_DIR
  FileUtils.rm_rf(Dir.glob("#{RAGIOS_HERCULES_SCREENSHOT_DIR}/*"))
end

RAGIOS_HERCULES_SCREENSHOT_DIR = "#{Dir.pwd}/screenshots/tmp"
RAGIOS_HERCULES_ENABLE_SCREENSHOTS = ENV['RAGIOS_HERCULES_ENABLE_SCREENSHOTS'] == 'true' ? true : false

RAGIOS_HERCULES_S3_DIR = ENV["RAGIOS_HERCULES_S3_DIR"]

def file_age(name)
  (Time.now - File.ctime(name))/(24*3600)
end

def clear_screenshots_cache!
  Dir.chdir(RAGIOS_HERCULES_SCREENSHOT_DIR)
  Dir.glob("*.*").each { |filename| File.delete(filename) if file_age(filename) > 1 }
end

if RAGIOS_HERCULES_ENABLE_SCREENSHOTS
  setup_screenshot_dir
  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['AWS_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY']
  )
  clear_screenshots_cache!
end

require_all '/uptime_monitor'
