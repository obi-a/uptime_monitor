require 'headless'
require 'watir-webdriver'
require 'watir-webdriver-performance'
require 'ostruct'
require 'active_support'
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

if RAGIOS_HERCULES_ENABLE_SCREENSHOTS
  setup_screenshot_dir
  AWS::S3::Base.establish_connection!(
    :access_key_id     => ENV['AMAZON_ACCESS_KEY_ID'],
    :secret_access_key => ENV['AMAZON_SECRET_ACCESS_KEY']
  )
end

require_all '/uptime_monitor'
