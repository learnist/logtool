module Logtool
  class Collator
    attr_reader :parser, :buffers

    def initialize(filenames)
      @parser = Logtool::Parser.new(filenames)
      @buffers = {}
    end

    def run
      previous_pid = nil

      parser.run do |line|
        current_pid = (line =~ /^\[\S+\] \[(\d+)\]/) ? $1 : previous_pid
        previous_pid = current_pid

        if start_of_transaction?(line, current_pid)
          if previous_buffer = buffers.delete(current_pid)
            yield previous_buffer
          end
          buffers[current_pid] = Buffer.new
        end

        if buffers.has_key?(current_pid)
          buffers[current_pid] << line

          if end_of_transaction?(line)
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
