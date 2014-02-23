#proof of concept
#rewite later
module Ragios
  module Plugin
    class UptimeMonitor
      attr_reader :monitor
      attr_reader :test_result
      attr_reader :state
      attr_reader :success

      def init(monitor)
        @state = :pending
        @monitor = OpenStruct.new(monitor)
        raise "A url must be provided for uptime_monitor in #{@monitor.monitor} monitor" if @monitor.url.nil?
      end

      def test_command?
        @test_result = ActiveSupport::OrderedHash.new
        @success = true
        @state = :pending
        browser_name = browser_eval(@monitor.browser)
        headless = is_headless(@monitor.browser)
        @web_browser = start_browser(@monitor.url, browser_name, headless)
        set_response_time
        verify_correct_page_title(@monitor.title?, @web_browser.page_title) if @monitor.title?
        parse_page_elements(@monitor.exists?) if @monitor.exists?
        @web_browser.close
        @success
      rescue Exception => e
        @web_browser.close
        raise e
      end

      def start_browser(url, browser_name, headless)
        Hercules::UptimeMonitor::Browser.new(url, browser_name, headless)
      end

      def verify_correct_page_title(monitor_title, browser_title)
        title_hash = text_reader("page title", monitor_title)
        @state = (text?("page title", title_hash, browser_title) == false) ? :failed : :passed
        @success = false if @state == :failed
        result = text_result(:page_title, title_hash, browser_title, @state)
        @test_result.merge!(result)
      end

      def set_response_time
        response_time = @web_browser.response_time
        @test_result.merge!({load_time_mili_secs: response_time})
      end

      #browser
      #["firefox", headless: true]
      #["firefox", headless: false]
      #["firefox"]
      def browser_reader(browser)
        error_message = "Invalid Browser: #{browser.inspect}"
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
      def browser_eval(browser)
        browser = browser_reader(browser)
        browser.first
      end

      def is_headless(browser)
        browser[1][:headless] if browser[1]
      end

      def parse_page_elements(page_elements)
        page_elements.each do |page_element|
          page_element = exists_reader(page_element)
          verify_correct_page_element(page_element)
        end
      end

      #page_element_array
      #[{div: {id:"test", class: "test-section"}}, [text: "this is a test"]]
      #page_element_hash
      #div: {id:"test", class: "test-section"}
      def verify_correct_page_element(page_element_array)
        page_element_hash = page_element_reader(page_element_array.first)
        page_element_exists = page_element_exists?(page_element_hash)
        @state = page_element_exists ? :passed : :failed
        @success = false if @state == :failed
        result = page_element_exists_result(page_element_hash, @state)
        @test_result.merge!(result)
        verify_correct_page_element_text(page_element_array)
      end

      def verify_correct_page_element_text(page_element_array)
        if page_element_has_text?(page_element_array)
          text_hash = text_reader("page element", page_element_array[1])
          page_element_hash = page_element_array.first
          if page_element_exists?(page_element_hash)
            @state = (text?("page element", text_hash, element.text) == false) ? :failed : :passed
            @success = false if @state == :failed
            result = text_result(:page_element,text_hash, element.text, @state)
            @test_result.merge!(result)
          end
        end
      end

      def page_element_exists_result(page_element_hash, state)
        if state == :passed
          {page_element_hash => :exists }
        elsif state == :failed
          {page_element_hash => :does_not_exist}
        end
      end

      #[{div: {id:"test", class: "test-section"}}, [text: "this is a test"]]
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
        @web_browser.page_element_exists?(element_hash)
      end

      def page_element_has_text?(page_element_array)
        page_element_array[1] == nil ? false : true
      end

      #text_hash format
      #{text: "Welcome to my site"}
      #{includes_text: "to my site"}
      def text_result(symbol, hash, text,state)
        if hash[:text]
          if state == :passed
            return {hash[:text] => "#{symbol}_text_matches_as_expected".to_sym}
          elsif state == :failed
            return {hash[:text] => {"#{symbol}_text_did_match_as_expected_got".to_sym => text}}
          end
        elsif hash[:includes_text]
          if state == :passed
            return {hash[:includes_text] => "#{symbol}_include_text_as_expected".to_sym}
          elsif state == :failed
            return {hash[:includes_text] => { "#{symbol}_did_not_include_expected_text_got".to_sym => text}}
          end
        else
          return {}
        end
      end

      #text_array format
      #[text: "Welcome to my site"]
      #[includes_text: "to my site"]
      def text_reader(symbol, text_array)
        raise "Invalid #{symbol} text: #{text_array.inspect}" unless text_array.is_a? Array
        raise "Invalid #{symbol} text: #{text_array.first.inspect}" unless text_array.first.is_a? Hash
        return text_array.first
      end

      #hash format
      #{text: "Welcome to my site"}
      #{includes_text: "to my site"}
      #text evaluator:
      def text?(symbol, hash, assert_eq_text)
        if hash[:text]
          hash[:text] == assert_eq_text
        elsif hash[:includes_text]
          assert_eq_text.include? hash[:includes_text]
        else
          raise "Could not evaluate #{symbol}: #{hash.inspect}"
        end
      end
    end
  end
end
