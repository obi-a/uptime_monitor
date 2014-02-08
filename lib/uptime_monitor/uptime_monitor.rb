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
        state = :pending
        browser = browser(@monitor.browser)
        browser.goto @monitor.url
        title_hash = title_reader(@monitor.title?)
        if title?(title_hash, browser.title) == false
          state = :failed
          result = failed_title_message(title_hash, browser.title)
          @test_result.merge!(result)
        end
        return false if state == :failed
      end

      #hash format
      #{text: "Welcome to my site"}
      #{includes_text: "to my site"}
      def failed_title_message(hash, browser_title)
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

      def browser(browser)
      end

    end
  end
end
