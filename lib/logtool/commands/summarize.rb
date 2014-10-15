module Logtool
  module Command
    class Summarize

      def run(args)

        if i = args.index('-o')
          args.delete_at(i)
          output = Logtool::Output.new(args.delete_at(i))
        else
          output = Logtool::Output.new($stdout)
        end

        Logtool::RailsCollator.new(args).run do |buffer|
          output.puts buffer.lines.grep(/<root> - Started|<actioncontroller> - (Processing|Parameters|current user|rails session|user agent|Completed)|<omniauth>|FATAL/)
          output.puts
        end
      end

    end
  end
end
