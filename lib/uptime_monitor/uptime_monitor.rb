module Ragios
  module Plugin
    class UptimeMonitor
      attr_reader :monitor
      attr_reader :test_result
      attr_reader :success

      def initialize
        @test_result = ActiveSupport::OrderedHash.new
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
        do_this_on_each_retry = Proc.new do |exception, try, elapsed_time, next_interval|
          $stderr.puts '-' * 80
          $stderr.puts "#{exception.class}: '#{exception.message}' - #{try} tries in #{elapsed_time} seconds and #{next_interval} seconds until the next try."
          $stderr.puts exception.backtrace.join("\n")
          $stderr.puts '-' * 80
          close_browser
        end
        Retriable.retriable on_retry: do_this_on_each_retry do
          @success = true
          browser_reader = Hercules::UptimeMonitor::BrowserReader.new(@monitor.browser)
          start_browser(@monitor.url, browser_reader.browser_name, browser_reader.headless)
          exists(@monitor.exists?)
          close_browser
          @success
        end
      rescue Exception => e
        close_browser
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
          @browser.exists?(page_element) ? result!(page_element, true) : result!(page_element, false)
        end
      end

      def result!(page_element, state)
        @success = false if state == false
        result = state ? {page_element => :exists_as_expected} : {page_element => :does_not_exist_as_expected}
        @test_result.merge!(result)
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
