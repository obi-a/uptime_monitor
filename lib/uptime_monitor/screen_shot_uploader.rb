module Hercules
  class ScreenShotUploader < CarrierWave::Uploader::Base
    storage :s3
  end
end
