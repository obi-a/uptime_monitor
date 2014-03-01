module Hercules
  module UptimeMonitor
    class Browser
      def initialize(url, browser_name = "firefox", is_headless = false)
        start_headless if is_headless
        goto(url,browser_name)
      end
      def page_title
        @browser.title
      end
      def close
        @browser.close
        @headless.destroy if @headless
      end
      def response_time
        @browser.performance.summary[:response_time]
      end
      def page_element_exists?(page_element)
        key, value = page_element.first
        element = @browser.send(key, value)
        element.exists?
      end

      def browser
        @browser
      end

    private
      def goto(url, browser_name)
        @browser = Watir::Browser.new browser_name
        @browser.goto url
      end
      def start_headless
        @headless = Headless.new
        @headless.start
        @headless
      end
    end
  end
end
