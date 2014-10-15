module Logtool
  class Collator
    attr_reader :processor, :buffers

    def initialize(filenames)
      @processor = Logtool::Parser.new(filenames)
      @buffers = {}
    end

    def run
      previous_pid = nil

      processor.run do |line|
        current_pid = (line =~ /^\[\S+\] \[(\d+)\]/) ? $1 : previous_pid
        previous_pid = current_pid

        if line =~ /INFO <root> - Started/ ||
          line =~ /INFO <actioncontroller> - Processing/ && !buffers.has_key?(current_pid)
          if previous_buffer = buffers.delete(current_pid)
            yield previous_buffer
          end
          buffers[current_pid] = Buffer.new
        end

        if buffers.has_key?(current_pid)
          buffers[current_pid] << line

          if line =~ /<actioncontroller> - Completed|<omniauth> - .* Request phase initiated/
            yield buffers.delete(current_pid)
          end
        end
      end

      buffers.each_value do |buffer|
        yield buffer
      end
    end
  end
end
