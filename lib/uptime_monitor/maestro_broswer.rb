module Hercules
  module Maestro
    class Browser
      attr_reader :browser
      attr_reader :parser
      attr_reader :s_expr
      def initialize(url, browser_name = "firefox", is_headless = false)
        @parser = Hercules::UptimeMonitor::MaestroLangParser.new
        @browser = Hercules::UptimeMonitor::Browser.new(url, browser_name, is_headless)
      end
      def exists?(script)
        @s_expr = @parser.parse(script).first
        @browser.exists? @s_expr
      end
      def close
        @browser.close
      end
    end
  end
end
