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
        browser_eval = browser_evaluator
        browser_name = browser_eval.eval(@monitor.browser)
        headless = browser_eval.is_headless(@monitor.browser)
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

      def browser_evaluator
        Hercules::UptimeMonitor::BrowserEvaluator.new
      end

      def text_evaluator
        Hercules::UptimeMonitor::TextEvaluator.new
      end

      def page_element_evaluator
        Hercules::UptimeMonitor::PageElementEvaluator.new
      end

      def verify_correct_page_title(monitor_title, browser_title)
        text_eval = text_evaluator
        title_hash = text_eval.read("page title", monitor_title)
        @state = (text_eval.text?("page title", title_hash, browser_title) == false) ? :failed : :passed
        @success = false if @state == :failed
        result = text_eval.result(:page_title, title_hash, browser_title, @state)
        @test_result.merge!(result)
      end

      def set_response_time
        response_time = @web_browser.response_time
        @test_result.merge!({load_time_mili_secs: response_time})
      end

      def parse_page_elements(page_elements)
        page_elements.each do |page_element|
          page_element = page_element_evaluator.exists_read(page_element)
          verify_correct_page_element(page_element)
        end
      end

      #page_element_array
      #[{div: {id:"test", class: "test-section"}}, [text: "this is a test"]]
      #page_element_hash
      #div: {id:"test", class: "test-section"}
      def verify_correct_page_element(page_element_array)
        page_element_eval = page_element_evaluator
        page_element_hash = page_element_eval.read(page_element_array.first)
        page_element_exists = page_element_exists?(page_element_hash)
        @state = page_element_exists ? :passed : :failed
        @success = false if @state == :failed
        result = page_element_eval.result(page_element_hash, @state)
        @test_result.merge!(result)
        verify_correct_page_element_text(page_element_array)
      end

      def verify_correct_page_element_text(page_element_array)
        if page_element_evaluator.has_text?(page_element_array)
          text_eval = text_evaluator
          text_hash = text_eval.read("page element", page_element_array[1])
          page_element_hash = page_element_array.first
          if page_element_exists?(page_element_hash)
            @state = (text_eval.text?("page element", text_hash, element.text) == false) ? :failed : :passed
            @success = false if @state == :failed
            result = text_eval.result(:page_element,text_hash, element.text, @state)
            @test_result.merge!(result)
          end
        end
      end

      def page_element_exists?(element_hash)
        @web_browser.page_element_exists?(element_hash)
      end
    end
  end
end
