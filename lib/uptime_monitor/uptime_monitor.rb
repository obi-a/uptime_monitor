module Ragios
  module Plugins
    class UptimeMonitor
      attr_reader :monitor
      attr_reader :test_result
      attr_reader :success
      attr_reader :screenshot_url
      attr_reader :has_screenshot
      attr_reader :browser_info
      attr_reader :s_expr
      attr_reader :validations

      def initialize
        @result_set = []
        @test_result = {results: @result_set}
      end

      def init(monitor)
        @monitor = OpenStruct.new(monitor)
        message = "A url must be provided for uptime_monitor: #{@monitor.monitor}"
        raise(Hercules::UptimeMonitor::NoUrlProvided.new(error: message), message) if @monitor.url.nil?
        message = "A browser must be provided for uptime_monitor: #{@monitor.monitor}"
        raise(Hercules::UptimeMonitor::NoBrowserProvided.new(error: message), message) if @monitor.browser.nil?
        @browser_info = Hercules::UptimeMonitor::BrowsersLangParser.new.parse(@monitor.browser)
        message = "A validation (exists?) must be provided for uptime_monitor: #{@monitor.monitor}"
        raise(Hercules::UptimeMonitor::NoValidationProvided.new(error: message), message) if @monitor.exists?.nil?
        @s_expr = Hercules::UptimeMonitor::MaestroLangParser.new.parse(@monitor.exists?)
        @validations = Hercules::UptimeMonitor::MaestroLangParser.new.parse(@monitor.exists?, description = true)
        {ok: true}
      end

      def test_command?
        @result_set = []
        @success = true
        @has_screenshot = false
        start_browser(@monitor.url, browser_info[:browser], !!browser_info[:headless] )
        exists(@s_expr)
        @test_result = {results: @result_set}
        @test_result[:screenshot] = @screenshot_url if @has_screenshot
        close_browser
        @success
      rescue Net::ReadTimeout => e
        close_browser rescue nil
        @test_result = {results: ["Page Load Timeout", "Page could not load after 2 minutes"]}
        return true
      rescue Exception => e
        close_browser rescue nil
        raise e
      end

      def close_browser
        @browser.close if @browser.respond_to?('close')
      end

      def start_browser(url, browser_name, headless)
        @browser = Hercules::UptimeMonitor::Browser.new(url, browser_name, headless)
      end

      def exists(page_elements)
        for i in 0..(page_elements.length - 1)
          if @browser.exists?(page_elements[i])
            result!(@validations[i], true)
          else
            take_screenshot
            result!(@validations[i], false)
          end
        end
      end

      def result!(validation, state)
        @success = false if state == false
        result = state ? [validation, "exists_as_expected"] : [validation, "does_not_exist_as_expected"]
        @result_set << result
      end

      def take_screenshot
        if RAGIOS_HERCULES_ENABLE_SCREENSHOTS && not(@monitor.disable_screenshots) && not(@has_screenshot)
          @screenshot_url = @browser.capture_screenshot
          @has_screenshot = true
        end
      end
    end
  end
end
module Hercules
  module UptimeMonitor
    class NoUrlProvided < StandardError; end
    class NoValidationProvided < StandardError; end
    class NoBrowserProvided < StandardError; end
  end
end
