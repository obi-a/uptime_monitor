module Hercules
  module UptimeMonitor
    class PageElement
      attr_reader :page_element_array
      def initialize(page_element_array)
        @page_element_array = read(page_element_array)
      end
      def element
      end
      def has_text?
      end
      def has_action?
      end
      def text
      end
      def action
      end
      def element_exists_result
      end
      def action_perform_result
      end
      def wait_until_result
      end
    private
      def read
      end
    end
  end
end
