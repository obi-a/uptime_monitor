require 'headless'
require 'watir-webdriver'
require 'watir-webdriver-performance'
require 'ostruct'
require 'active_support'
require 'carrierwave'
require 'aws'

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

if RAGIOS_HERCULES_ENABLE_SCREENSHOTS
  setup_screenshot_dir
  CarrierWave.configure do |config|
    config.s3_access_key_id =  ENV['AWS_ACCESS_KEY_ID']
    config.s3_secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
    config.s3_bucket = ENV['RAGIOS_HERCULES_S3_DIR']
  end
  CarrierWave.clean_cached_files! 
end

require_all '/uptime_monitor'
