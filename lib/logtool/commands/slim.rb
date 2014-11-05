module Logtool
  module Command
    class Slim

      def run(args)
        sources = args.map{|arg| Logtool::Source.new(arg) }
        Logtool::RailsCollator.new(sources).run do |buffer|

          # Filter patterns that are applicable to any Rails project
          lines = buffer.lines.
            reject{|line| line =~ /<activerecord>.*SELECT/ }.
            reject{|line| line =~ /<actioncontroller>.*Rendered/ }

          # Specific patterns for Learnist
          lines.reject!{|line| line =~ /<tiberius>/ }

          puts lines
          puts
        end
      end

      def exit_with_usage
        $stderr.puts "usage: logtool slim [args...]"
        exit 1
      end
    end
  end
end
