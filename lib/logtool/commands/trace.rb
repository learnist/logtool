module Logtool
  module Command
    class Trace

      #options = {}
      #OptionParser.new do |opts|
      #  opts.banner = "Usage: collate-unicorn-logs.rb [options] [log files...]"
      #  opts.on("-i", "--ip IP_ADDRESS", "ip address") {|value| options[:ip_address] = value }
      #end.parse!

      def run(args)

        args.each do |arg|
          io = case arg
            when '-' then $stdin
            when /\.gz$/ then IO.popen("gunzip -c #{arg}")
            else File.open(arg)
          end

          io.each do |line|
            begin
              if line =~ /^\[\S+\] \[(\d+)\]/
                current_pid = $1
              else
                current_pid = previous_pid
              end
            rescue ArgumentError => e
              $stderr.puts "* warning: utf-8 encoding error in '#{line}'"
              next
            end
            previous_pid = current_pid

            if line =~ /INFO <root> - Started (?:GET|POST|PUT|DELETE) .* for (\S+)/
              flush_buffer(current_pid)
              if $1 == options[:ip_address]
                $buffers_by_pid[current_pid] = Buffer.new
                if $buffers_by_pid.size > 1
                  puts "WARNING: multiple concurrent requests detected; pids = #{$buffers_by_pid.keys.inspect}. Requests will be printed in order of completion.\n\n"
                end
              end
            end

            if current_buffer = $buffers_by_pid[current_pid]
              current_buffer << line
              current_buffer.error! if line =~ /FATAL/

              flush_buffer(current_pid) if line =~ /<actioncontroller> - Completed [234]/
              flush_buffer(current_pid) if line.empty? && current_buffer.error?
            end
          end

          io.close unless io == $stdin
        end

        flush_all
      end

    end
  end
end
