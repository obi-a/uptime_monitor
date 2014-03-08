module Ragios
  module Plugin
    class UptimeMonitor
      attr_reader :monitor
      attr_reader :test_result
      attr_reader :success

      def init(monitor)
        @monitor = OpenStruct.new(monitor)
        raise "A url must be provided for uptime_monitor in #{@monitor.monitor} monitor" if @monitor.url.nil?
      end

      def test_command?
        @test_result = ActiveSupport::OrderedHash.new
        return true unless @monitor.exists?
        @success = true
        browser_reader = Hercules::UptimeMonitor::BrowserReader.new(@monitor.browser)
        @browser = start_browser(@monitor.url, browser_reader.browser_name, browser_reader.headless)
        exists(@monitor.exists?)
        @browser.close
        @success
      rescue Exception => e
        @browser.close
        raise e
      end

      def start_browser(url, browser_name, headless)
        Hercules::UptimeMonitor::Browser.new(url, browser_name, headless)
      end

      def exists(page_elements)
        page_elements.each do |page_element|
          @browser.exists?(page_element) ? result!(page_element, true) : result!(page_element, false)
        end
      end

      def result!(page_element, state)
        @success = state
        result = state ? {page_element => :exists_as_expected} : {page_element => :does_not_exist_as_expected}
        @test_result.merge!(result)
      end
    end
  end
end
