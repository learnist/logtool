module Logtool
  module Command
    class Trace

      def run(args)
        search_term = args.shift

        processor_method = case search_term
          when /^\d+\.\d+\.\d+\.\d+$/  then :trace_by_ip_address
          when /^\d+$/                 then :trace_by_user_id
          when /@/                     then :trace_by_email
          else
            $stderr.puts "usage: logtool trace ( <ip-addr> | <user-id> | <email> )  [args...]"
            exit 1
        end

        sources = args.map{|arg| Logtool::Source.new(arg) }
        collator = Logtool::RailsCollator.new(sources)

        send(processor_method, collator, search_term) do |buffer|
          if concurrent_pids = buffer.concurrent_pids
            noun = concurrent_pids.size == 1 ? "pid #{concurrent_pids.first}" : "pids #{concurrent_pids.inspect}"
            puts "WARNING: concurrent requests detected for client at #{buffer.ip_addr}: pid #{buffer.pid} began before #{noun} completed.\n\n"
          end
          puts buffer.lines
          puts
        end
      end

      def trace_by_ip_address(collator, ip_address, &block)
        collator.run do |buffer|
          if buffer.lines.first =~ /Started .* for #{ip_address} at /
            yield buffer
          end
        end
      end

      def trace_by_user_id(collator, user_id, &block)
        collator.run do |buffer|
          if buffer.lines.any? {|line| line =~ /current user: #{user_id} / }
            yield buffer
          end
        end
      end

      def trace_by_email(collator, email, &block)
        collator.run do |buffer|
          if buffer.lines.any? {|line| line =~ /current user: \d+ \(.*, #{email}\)/ }
            yield buffer
          end
        end
      end

    end
  end
end
