module Logtool
  module Command
    class Summarize

      def run(args)

        if i = args.index('-o')
          args.delete_at(i)
          sink = Logtool::Sink.new(args.delete_at(i))
        else
          sink = Logtool::Sink.new($stdout)
        end

        Logtool::RailsCollator.new(args).run do |buffer|
          sink.puts buffer.lines.grep(/<root> - Started|<actioncontroller> - (Processing|Parameters|current user|rails session|user agent|Completed)|<omniauth>|FATAL/)
          sink.puts
        end
      end

    end
  end
end
