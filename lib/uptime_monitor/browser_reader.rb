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
        error_message = "Invalid Browser: #{browser.inspect}"
        raise error_message unless @browser.is_a? Array
        raise error_message unless @browser.first.is_a? String
        if browser.length > 1
          raise error_message unless @browser[1].is_a? Hash
          raise error_message unless [TrueClass, FalseClass].include? @browser[1][:headless].class
        end
      end
      def eval
        read
        @browser.first
      end
    end
  end
end
