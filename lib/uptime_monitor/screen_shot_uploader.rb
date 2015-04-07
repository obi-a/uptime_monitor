module Hercules
  module UptimeMonitor
    class ScreenShotUploader < CarrierWave::Uploader::Base
      storage :s3
    end
  end
end
