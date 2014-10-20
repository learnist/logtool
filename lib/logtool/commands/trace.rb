module Logtool
  module Command
    class Trace

      def run(args)
        unless ip_address = args.shift
          $stderr.puts "usage: logtool trace <ip-addr> [args...]"
          exit 1
        end

        sources = args.map{|arg| Logtool::Source.new(arg) }
        Logtool::RailsCollator.new(sources).run do |buffer|
          if buffer.lines.first =~ /Started .* for #{ip_address} at /
            if concurrent_pids = buffer.concurrent_pids
              noun = concurrent_pids.size == 1 ? "pid #{concurrent_pids.first}" : "pids #{concurrent_pids.inspect}"
              puts "WARNING: concurrent requests detected for client at #{buffer.ip_addr}: pid #{buffer.pid} began before #{noun} completed.\n\n"
            end
            puts buffer.lines
            puts
          end
        end
      end

    end
  end
end
