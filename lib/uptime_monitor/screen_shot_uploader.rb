module Hercules
  module UptimeMonitor
    class ScreenShotUploader
      def store(file)
        current_key = "screenshot#{Time.now.to_i}.png"
        AWS::S3::S3Object.store(current_key, open(file), RAGIOS_HERCULES_S3_DIR)
        AWS::S3::S3Object.url_for(
          current_key,
          RAGIOS_HERCULES_S3_DIR,
          use_ssl: true,
          expires_in: 31557600
        )
      end
    end
  end
end
