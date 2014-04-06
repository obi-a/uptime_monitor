module Hercules
  module UptimeMonitor
    class Browser
      def initialize(url, browser_name = "firefox", is_headless = false)
        start_headless if is_headless
        goto(url,browser_name)
      end
      def close
        @browser.close
        @headless.destroy if @headless
      end
      def rest(page_element)
        page_element[1..-1]
      end
      def exists?(page_element)
        message = "Invalid page element format: #{page_element.inspect}"
        raise(Hercules::UptimeMonitor::InvalidPageElementForm.new(error: message), message) unless page_element.is_a?(Array)
        is_wait_until?(page_element.first) ? apply_wait_until?(page_element.first[:wait_until_exists?]) : page_element_exists?(page_element)
      end
      def page_element_exists?(page_element)
        element = get_element(page_element.first)
        begin
          first_exists = element.exists?
        rescue Exception => e
          message = "Cannot find page element in this form: #{page_element.first.inspect}, you may use a css selector form"
          raise(Hercules::UptimeMonitor::UnknownPageElement.new(error: message), message)
        end
        if first_exists && !rest(page_element).empty?
          rest_exists?(element, rest(page_element))
        else
          first_exists
        end
      end
      def get_element(first)
        if (first.is_a? Symbol) || (first.is_a? String)
          first.to_sym
          @browser.send(first)
        elsif first.is_a? Hash
          key, value = first.first
          @browser.send(key, value)
        else
          message = "Invalid page element #{first.inspect}"
          raise(Hercules::UptimeMonitor::InvalidPageElement.new(error: message), message)
        end
      end
      def rest_exists?(element, array)
       results = array.map { |e| apply_rest?(element, e) }
       results.include?(false) ? false : true
      end
      def apply_rest?(element, array)
        if is_a_text?(array)
          apply_text?(element.text, array.first)
        elsif is_an_action?(array)
          apply_action?(element, array.first)
        else
          message = "Invalid options: #{array.inspect}"
          raise(Hercules::UptimeMonitor::InvalidRest.new(error: message), message)
        end
      end
      def is_a_text?(text_array)
        if text_array.is_a? Array
          if text_array.first.is_a? Hash
            text_hash = text_array.first
            key, value = text_hash.first
            if (([:text, :includes_text].include?(key)) && (value.is_a? String))
             return true
            end
          end
        end
        return false
      end
      def is_an_action?(array)
        if array.is_a? Array
          if array.first.is_a?(Symbol) || array.first.is_a?(Hash)
            return true
          end
        end
        return false
      end
      def is_wait_until?(hash)
        return false unless hash.is_a? Hash
        key, value = hash.first
        key == :wait_until_exists?
      end
      def apply_text?(assert_eq_text, text_hash)
        if text_hash[:text]
          text_hash[:text] == assert_eq_text
        elsif text_hash[:includes_text]
          assert_eq_text.include? text_hash[:includes_text]
        else
          message = "Could not evaluate page_element text: #{text_hash.inspect}"
          raise(Hercules::UptimeMonitor::InvalidText.new(error: message), message)
        end
      end
      def apply_action?(element, action)
        if action.is_a? Symbol
          element.send(action)
        elsif action.is_a? Hash
          key, value = action.first
          element.send(key, value)
        else
          message = "Cannot apply action: #{action.inspect}"
          raise(Hercules::UptimeMonitor::InvalidAction.new(error: message), message)
        end
        true
      end
      def apply_wait_until?(page_element)
        Watir::Wait.until { page_element_exists?(page_element) }
        true
      rescue Watir::Wait::TimeoutError
        false
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

class String
  def exists?
    true
  end
  def text
    self
  end
end

module Hercules
  module UptimeMonitor
    class InvalidAction < StandardError; end
    class InvalidText < StandardError; end
    class InvalidRest < StandardError; end
    class InvalidPageElement < StandardError; end
    class UnknownPageElement < StandardError; end
    class InvalidPageElementForm < StandardError; end
  end
end
