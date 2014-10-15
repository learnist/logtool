module Logtool
  module Command
    class Trace

      def run(args)
        unless ip_address = args.shift
          $stderr.puts "usage: logtool trace <ip-addr> [args...]"
          exit 1
        end

        Logtool::Collator.new(args).run do |buffer|
          if buffer.lines.first =~ /Started .* for #{ip_address}/
            puts buffer.lines
            puts
          end
        end
      end

      # lost functionality:
      # puts "WARNING: multiple concurrent requests detected; pids = #{$buffers_by_pid.keys.inspect}. Requests will be printed in order of completion.\n\n"
    end
  end
end
