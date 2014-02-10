#rewite later
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
        @browser = goto(@monitor.url, browser_name)
        verify_correct_page_title(@monitor.title?, browser.title) if @monitor.title?
        parse_page_elements(@monitor.exists?) if @monitor.exists?
        @browser.close
        headless.destroy if @headless
        @state == :failed ? false : true
      end

      def verify_correct_page_title(monitor_title, browser_title)
          title_hash = text_reader(monitor_title)
          @state = (text?(title_hash, browser_title) == false) ? :failed : :passed
          result = text_result(title_hash, browser_title)
          @test_result.merge!(result)
      end

      #browser
      #["firefox", headless: true]
      #["firefox", headless: false]
      #["firefox"]
      def browser_reader(browser)
        error_message = "Invalid Browser in #{browser.inspect}"
        raise error_message unless browser.is_a? Array
        raise error_message unless browser.first.is_a? String
        if browser.length > 1
          raise error_message unless browser[1].is_a? Hash
          raise error_message unless [TrueClass, FalseClass].include? browser[1][:headless].class
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

      def parse_page_elements(page_elements)
        page_elements = exists_reader(page_elements)
        page_elements.each do |page_element|
          verify_correct_page_element(page_element)
        end
      end

      #page_element_array
      #[div: {id:"test", class: "test-section"}, text: "this is a test"]
      #page_element_hash
      #div: {id:"test", class: "test-section"}
      def verify_correct_page_element(page_element_array)
        page_element_hash = page_element_reader(page_element_array.first)
        page_element_exists = page_element_exists?(page_element_hash)
        @state = page_element_exists ? :passed : :falied
        result = page_element_exists_result(page_element_hash, @state)
        @test_result.merge!(result)
        verify_correct_page_element_text(page_element_array)
      end

      def verify_correct_page_element_text(page_element_array)
        if page_element_has_text?(page_element_array)
          text_hash = text_reader(page_element_array[1])
          page_element_hash = page_element_array.first
          element = get_page_element(page_element_hash)
          @state = (text?(text_hash, element.text) == false) ? :failed : :passed
          result = text_result(text_hash, element.text)
          @test_result.merge!(result)
        end
      end

      def page_element_exists_result(page_element_hash, state)
        key, value = page_element_hash
        if state == true
          {exists: "#{key.inspect} with #{value.inspect}"}
        elsif state == false
          {does_not_exist: "#{key.inspect} with #{value.inspect}"}
        end
      end

      #[div: {id:"test", class: "test-section"}, text: "this is a test"]
      def exists_reader(page_element_array)
        error_message = "Invalid page element in #{page_element_array.inspect}"
        raise error_message unless page_element_array.is_a? Array
        raise error_message unless page_element_array.first.is_a? Hash
        return page_element_array
      end

      #page_element_hash format
      #{div: {id:"test", class: "test-section"}}
      def page_element_reader(page_element_hash)
        error_message = "Invalid page element in #{page_element_hash.inspect}"
        raise error_message unless page_element_hash.is_a? Hash
        key, value = page_element_hash.first
        raise error_message unless key.is_a? Symbol
        raise error_message unless value.is_a? Hash
        return page_element_hash
      end

      def page_element_exists?(element_hash)
        element = get_page_element(element_hash)
        element.exists?
      end

      def page_element_text_reader(text_array)
        text_hash = text_reader(text_array)
      end

      def page_element_text?(text_hash, element_text)
        text?(text_hash, element_text)
      end

      def page_element_has_text?(page_element_array)
        page_element_array[1] == nil ? false : true
      end

      #page_element_hash format
      #{div: {id:"test", class: "test-section"}}
      def get_page_element(page_element_hash)
        key, value = page_element_hash.first
        element_object = @browser.send(key, value)
      end

      #text_hash format
      #{text: "Welcome to my site"}
      #{includes_text: "to my site"}
      def text_result(hash, browser_title)
        if hash[:text]
          {expected_page_title: hash[:text], got: browser_title}
        elsif hash[:includes_text]
          {expected_page_title_to_include: hash[:includes_text], got: browser_title}
        else
          {}
        end
      end

      #text_array format
      #[text: "Welcome to my site"]
      #[includes_text: "to my site"]
      def text_reader(text_array)
        #add custom exception later
        error_message =
        raise "Invalid text in #{text_array.inspect}" unless text_array.is_a? Array
        raise "Invalid text in #{text_array.first.inspect}" unless text_array.first.is_a? Hash
        return text_array.first
      end

      #hash format
      #{text: "Welcome to my site"}
      #{includes_text: "to my site"}
      #text evaluator:
      def text?(hash, assert_eq_text)
        if hash[:text]
          hash[:text] == assert_eq_text
        elsif hash[:includes_text]
          assert_eq_text.include? hash[:includes_text]
        else
          raise "Could not evaluate title"
        end
      end
    end
  end
end
