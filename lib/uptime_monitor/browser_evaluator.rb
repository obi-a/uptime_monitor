module Hercules
  module UptimeMonitor
    class BrowserEvaluator
      #browser form
      #["firefox", headless: true]
      #["firefox", headless: false]
      #["firefox"]
      def read(browser)
        error_message = "Invalid Browser: #{browser.inspect}"
        raise error_message unless browser.is_a? Array
        raise error_message unless browser.first.is_a? String
        if browser.length > 1
          raise error_message unless browser[1].is_a? Hash
          raise error_message unless [TrueClass, FalseClass].include? browser[1][:headless].class
        end
        return browser
      end
      def eval(browser)
        browser = read(browser)
        browser.first
      end
      def is_headless(browser)
        browser[1][:headless] if browser[1]
      end
    end
  end
end
