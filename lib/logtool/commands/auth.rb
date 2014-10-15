module Logtool
  module Command
    class Auth

      def run(args)

        if i = args.index('-o')
          args.delete_at(i)
          output = Logtool::Output.new(args.delete_at(i))
        else
          output = Logtool::Output.new($stdout)
        end

        Logtool::TransactionCollator.new(args).run do |buffer|
          if buffer.lines[0] =~ %r{/v3/auth/twitter(/callback)?\b} ||
              buffer.lines[1] =~ /V3::AuthController#(login|logout|signup)/
            output.puts buffer.lines
            output.puts
          end
        end
      end

    end
  end
end
