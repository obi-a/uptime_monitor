module Hercules
  module UptimeMonitor
    class TextEvaluator
      attr_reader :text_array
      #text_array format
      #[text: "Welcome to my site"]
      #[includes_text: "to my site"]
      #text format
      #{text: "Welcome to my site"}
      def initialize(text_array)
        @text_array = read(text_array)
        @text = text_array.first
      end

      def text
        @text
      end

      def match?(assert_eq_text)
        if @text[:text]
          @text[:text] == assert_eq_text
        elsif @text[:includes_text]
          assert_eq_text.include? @text[:includes_text]
        else
          raise "Could not evaluate page_element text: #{@text.inspect}"
        end
      end
      def result(text, state)
        if @text[:text]
          if state == :passed
            return {@text[:text] => "page_element_text_matches_as_expected".to_sym}
          elsif state == :failed
            return {@text[:text] => {"page_element_text_did_match_as_expected_got".to_sym => text}}
          end
        elsif @text[:includes_text]
          if state == :passed
            return {@text[:includes_text] => "page_element_text_include_text_as_expected".to_sym}
          elsif state == :failed
            return {@text[:includes_text] => { "page_element_text_did_not_include_expected_text_got".to_sym => text}}
          end
        else
          return {}
        end
      end
    private
      def read(text_array)
        raise "Invalid page element text: #{text_array.inspect}" unless text_array.is_a? Array
        raise "Invalid page element text: #{text_array.first.inspect}" unless text_array.first.is_a? Hash
        return text_array.first
      end
    end
  end
end
