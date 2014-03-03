module Hercules
  module UptimeMonitor
    class PageElementEvaluator
      #page_element_array form
      #[{div: {id:"test", class: "test-section"}}, [text: "this is a test"]]
      def exists_read(page_element_array)
        error_message = "Invalid page element in #{page_element_array.inspect}"
        raise error_message unless page_element_array.is_a? Array
        raise error_message unless page_element_array.first.is_a? Hash
        return page_element_array
      end
      #page_element_hash form
      #{div: {id:"test", class: "test-section"}}
      def read(page_element_hash)
        error_message = "Invalid page element in #{page_element_hash.inspect}"
        raise error_message unless page_element_hash.is_a? Hash
        key, value = page_element_hash.first
        raise error_message unless key.is_a? Symbol
        raise error_message unless value.is_a? Hash
        return page_element_hash
      end
      def has_text?(page_element_array)
        page_element_array[1] == nil ? false : true
      end
      def exists_result(page_element_hash, state)
        if state == :passed
          {page_element_hash => :exists }
        elsif state == :failed
          {page_element_hash => :does_not_exist}
        end
      end
    end
  end
end
