require 'treetop'

module Hercules
  module UptimeMonitor
    class Parser
      def self.parse(data, parser, description = false)
        if data.respond_to? :read
          data = data.read
        end

        ast = parser.parse data

        if ast
          return (description ? ast.description : ast.content)
        else
          parser.failure_reason =~ /^(Expected .+) after/m
          message =
          "#{$1.gsub("\n", '$NEWLINE')}:" << "\n" <<
          data.lines.to_a[parser.failure_line - 1] << "\n" <<
          "#{'~' * (parser.failure_column - 1)}^"
          raise(Hercules::UptimeMonitor::SyntaxError.new(error: message), message)
        end
      end

    end

    class MaestroLangParser
      Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'maestro')))
      @@maestro_parser = MaestroParser.new
      def parse(data, description = false)
        Hercules::UptimeMonitor::Parser.parse(data, @@maestro_parser, description)
      end
    end

    class BrowsersLangParser
      Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'browsers')))
      @@browsers_parser = BrowsersParser.new
      def parse(data)
        Hercules::UptimeMonitor::Parser.parse(data, @@browsers_parser)
      end
    end

    class SyntaxError < StandardError; end
  end
end
