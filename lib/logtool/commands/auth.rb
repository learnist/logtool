module Logtool
  module Command
    class Auth

      def run(args)
        if i = args.index('-o')
          # TODO: generalize the handling of the -o option to other commands
          args.delete_at(i)
          sink = Logtool::Sink.new(args.delete_at(i))
        else
          sink = Logtool::Sink.new($stdout)
        end

        Logtool::RailsCollator.new(args).run do |buffer|
          if buffer.lines[0] =~ %r{/v3/auth/twitter(/callback)?\b} ||
              buffer.lines[1] =~ /V3::AuthController#(login|logout|signup)/
            sink.puts buffer.lines
            sink.puts
          end
        end
      end

    end
  end
end
