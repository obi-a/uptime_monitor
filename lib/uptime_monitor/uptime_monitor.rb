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

      def create_page_element
        Hercules::UptimeMonitor::PageElement.new
      end

      def set_response_time
        response_time = @web_browser.response_time
        @test_result.merge!({load_time_mili_secs: response_time})
      end

      def parse_page_elements(page_elements)
        page_elements.each do |page_element|
          verify_correct_page_element(page_element)
        end
      end
      #DRY UP later
      def apply_action(page_element_array)
        page_element = create_page_element(page_element_array)
        if page_element.has_action?
          @state = @web_browser.action?(page_element.element, page_element.action) ? :passed : :failed
          @success  = false if @state == :failed
          result = page_element.action_performed_result(@state)
          @test_result.merge!(result)
        end
      end

      def verify_correct_page_element(page_element_array)
        page_element = create_page_element(page_element_array)
        if page_element.is_wait_until?
          wait_until(page_element.wait_until_element)
        else
          @state = page_element_exists?(page_element.element) ? :passed : :failed
          @success = false if @state == :failed
          result = page_element.exists_result(@state)
          @test_result.merge!(result)
          verify_correct_page_element_text(page_element_array)
          apply_action(page_element_array)
        end
      end

      def wait_until(page_element)
        @state = @web_browser.wait_until_element?(page_element) ? :passed : :failed
        @success = false if @state == :failed
        result = page_element.wait_until_result(@state)
        @test_result.merge!(result)
      end

      def verify_correct_page_element_text(page_element_array)
        page_element = create_page_element(page_element_array)
        if page_element.has_text?
          text = text_evaluator(page_element.text)
          if page_element_exists?(page_element.element)
            element_text = @web_browser.page_element_text(page_element.element)
            @state = (text.match?(element_text) == false) ? :failed : :passed
            @success = false if @state == :failed
            result = text.result(element_text, @state)
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
