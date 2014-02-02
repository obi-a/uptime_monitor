module Ragios
  module Plugin
    class UptimeMonitor
      attr_reader :monitor
      attr_reader :test_result
      attr_reader :state

      def init(monitor)
        @state = :pending
        @monitor = OpenStruct.new(monitor)
        raise "A url must be provided for uptime_monitor in #{@monitor.monitor} monitor" if @monitor.url.nil?
      end

      def test_command?
        @test_result = {}
        browser = browser(@monitor.browser)
        browser.goto @monitor.url
        @test_result.merge! test_page_title(browser.title, @monitor.title?) if @monitor.title?
        @state = test_page_title_state_transition(browser.title, @monitor.title?)
      end

      def exists(element)
      end

      def exists?(element)
      end

      def test_page_title(browser_title, monitor_title)
        if equal(browser_title, monitor_title)
          result = {}
        else
          result = {expected_page_title: monitor_title, got: browser_title}
        end
      end

      def browser(browser)
      end

      def test_page_title_state_transition(browser_title, monitor_title)
        return :passed  if equal(browser_title, monitor_title)
        return :failed unless equal(browser_title, monitor_title)
      end

    private

      def equal(right, left)
        right == left
      end
    end
  end
end