module Ragios
  module Plugin
    class UptimeMonitor
      attr_reader :monitor
      attr_reader :test_result
      attr_reader :success

      def initialize
        @test_result = ActiveSupport::OrderedHash.new
        @result_set = []
        @test_result = {results: @result_set }
      end

      def init(monitor)
        @monitor = OpenStruct.new(monitor)
        message = "A url must be provided for uptime_monitor: #{@monitor.monitor}"
        raise(Hercules::UptimeMonitor::NoUrlProvided.new(error: message), message) if @monitor.url.nil?
        message = "A browser must be provided for uptime_monitor: #{@monitor.monitor}"
        raise(Hercules::UptimeMonitor::NoBrowserProvided.new(error: message), message) if @monitor.browser.nil?
        message = "A validation (exists?) must be provided for uptime_monitor: #{@monitor.monitor}"
        raise(Hercules::UptimeMonitor::NoValidationProvided.new(error: message), message) if @monitor.exists?.nil?
      end

      def test_command?
        @result_set = []
        @success = true
        @has_screenshot = false
        browser_reader = Hercules::UptimeMonitor::BrowserReader.new(@monitor.browser)
        start_browser(@monitor.url, browser_reader.browser_name, browser_reader.headless)
        exists(@monitor.exists?)
        @test_result = {results: @result_set }
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
        page_elements.each do |page_element|
          if @browser.exists?(page_element) 
            result!(page_element, true) 
          else 
            take_screenshot
            result!(page_element, false)
          end
        end
      end

      def result!(page_element, state)
        @success = false if state == false
        result = state ? [page_element, "exists_as_expected"] : [page_element, "does_not_exist_as_expected"]
        @result_set << result
      end

      def take_screenshot
        if not(@has_screenshot) 
          @browser.capture_screenshot 
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
