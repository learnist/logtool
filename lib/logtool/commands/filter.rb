module Logtool
  module Command
    class Filter

      def run(args)
        inclusions, exclusions = [], []
        while args.any? && args.first =~ /^--/
          case args.shift
            when '--include'; inclusions << args.shift
            when '--exclude'; exclusions << args.shift
            else exit_with_usage
          end
        end

        if inclusions.empty? && exclusions.empty?
          exit_with_usage
        end

        sources = args.map{|arg| Logtool::Source.new(arg) }

        Logtool::RailsCollator.new(sources).run do |buffer|
          next unless endpoint = buffer.lines[1][/Processing by (\S+)/, 1]

          if (inclusions.empty? || inclusions.include?(endpoint)) && !exclusions.include?(endpoint)
            puts buffer
            puts
          end
        end
      end

      def exit_with_usage
        $stderr.puts "usage: logtool filter [ --include <endpoint> | --exclude <endpoint>] ..."
        exit 1
      end
    end
  end
end
