module Ragios
  module Plugin
    class UptimeMonitor
      attr_reader :monitor
      attr_reader :test_result
      attr_reader :state
      attr_reader :headless

      def init(monitor)
        @state = :pending
        @monitor = OpenStruct.new(monitor)
        raise "A url must be provided for uptime_monitor in #{@monitor.monitor} monitor" if @monitor.url.nil?
      end

      def test_command?
        @test_result = {}
        @state = :pending
        browser_name = browser(@monitor.browser)
        headless = start_headless if @headless
        browser = goto(@monitor.url, browser_name)
        verify_correct_page_title(@monitor.title?, browser.title)
        browser.close
        headless.destroy if @headless
        @state == :failed ? false : true
      end

      def verify_correct_page_title(monitor_title, browser_title)
        if monitor_title
          title_hash = title_reader(monitor_title)
          @state = (title?(title_hash, browser_title) == false) ? :failed : :passed
          result = title_result(title_hash, browser_title)
          @test_result.merge!(result)
        end
      end

      def goto(url, browser_name)
        browser = Watir::Browser.new browser_name
        browser.goto url
        return browser
      end

      def start_headless
        headless = Headless.new
        headless.start
        return headless
      end


      #hash format
      #{text: "Welcome to my site"}
      #{includes_text: "to my site"}
      def title_result(hash, browser_title)
        if hash[:text]
          {expected_page_title: hash[:text], got: browser_title}
        elsif hash[:includes_text]
          {expected_page_title_to_include: hash[:includes_text], got: browser_title}
        else
          {}
        end
      end

      #title format
      #[text: "Welcome to my site"]
      #[includes_text: "to my site"]
      def title_reader(title)
        #add custom exception later
        raise "Invalid title" unless title.class == Array
        raise "Invalid title" unless title.first.class == Hash
        return title.first
      end

      #hash format
      #{text: "Welcome to my site"}
      #{includes_text: "to my site"}
      #title evaluator:
      def title?(hash, browser_title)
        if hash[:text]
          hash[:text] == browser_title
        elsif hash[:includes_text]
          browser_title.include? hash[:includes_text]
        else
          raise "Could not evaluate title"
        end
      end

      def exists(element)
      end

      def exists?(element)
      end

      #browser
      #["firefox", headless: true]
      #["firefox", headless: false]
      #["firefox"]
      def browser_reader(browser)
        raise "Invalid Browser" unless browser.class == Array
        raise "Invalid Browser" unless browser.first.class == String
        if browser.length > 1
          raise "Invalid Browser" unless browser[1].class == Hash
          raise "Invalid Browser" unless [TrueClass, FalseClass].include? browser[1][:headless].class
        end
        return browser
      end

      #browser
      #["firefox", headless: true]
      #["firefox", headless: false]
      #["firefox"]
      def browser(browser)
        @headless = browser[1][:headless] if browser[1]
        browser.first
      end

    end
  end
end
