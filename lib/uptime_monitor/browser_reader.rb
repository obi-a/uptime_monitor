module Hercules
  module UptimeMonitor
    class BrowserReader
      attr_reader :browser
      attr_reader :browser_name
      def initialize(browser)
        @browser = browser
        @browser_name = eval
      end
      def headless
        @browser[1] ? @browser[1][:headless] : false
      end
    private
      #browser form
      #["firefox", headless: true]
      #["firefox", headless: false]
      #["firefox"]
      def read
        message = "Invalid Browser: #{@browser.inspect}"
        raise(Hercules::UptimeMonitor::InvalidBrowserForm.new(error: message), message) unless @browser.is_a? Array
        raise(Hercules::UptimeMonitor::InvalidBrowserForm.new(error: message), message) unless @browser.first.is_a? String
        if browser.length > 1
          error_message = "Invalid setting for headless browser in #{@browser.inspect}"
          raise(Hercules::UptimeMonitor::InvalidHeadlessForm.new(error: message), message) unless @browser[1].is_a? Hash
          raise(Hercules::UptimeMonitor::InvalidHeadlessForm.new(error: message), message) unless [TrueClass, FalseClass].include? @browser[1][:headless].class
        end
      end
      def eval
        read
        @browser.first
      end
    end
  end
end

module Hercules
  module UptimeMonitor
    class InvalidBrowserForm < StandardError; end
    class InvalidHeadlessForm < StandardError; end
  end
end
