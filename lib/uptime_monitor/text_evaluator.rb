module Hercules
  module UptimeMonitor
    class TextEvaluator
      #text_array format
      #[text: "Welcome to my site"]
      #[includes_text: "to my site"]
      def read(symbol, text_array)
        raise "Invalid #{symbol} text: #{text_array.inspect}" unless text_array.is_a? Array
        raise "Invalid #{symbol} text: #{text_array.first.inspect}" unless text_array.first.is_a? Hash
        return text_array.first
      end
      #hash format
      #{text: "Welcome to my site"}
      #{includes_text: "to my site"}
      def text?(symbol, hash, assert_eq_text)
        if hash[:text]
          hash[:text] == assert_eq_text
        elsif hash[:includes_text]
          assert_eq_text.include? hash[:includes_text]
        else
          raise "Could not evaluate #{symbol}: #{hash.inspect}"
        end
      end
      def result(symbol, hash, text, state)
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
    end
  end
end
