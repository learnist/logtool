module Logtool
  class Collator
    attr_reader :parser, :buffers, :current_line, :current_pid

    def initialize(filenames)
      @parser = Logtool::Parser.new(filenames)
      @buffers = {}
    end

    def run
      previous_pid = nil

      parser.run do |line|
        @current_line = line
        @current_pid = (line =~ /^\[\S+\] \[(\d+)\]/) ? $1 : previous_pid
        previous_pid = current_pid

        if start_of_transaction?
          if previous_buffer = buffers.delete(current_pid)
            yield previous_buffer
          end
          buffers[current_pid] = Buffer.new(current_pid)
          handle_start_of_transaction
        end

        if current_buffer
          current_buffer << line

          if end_of_transaction?
            handle_end_of_transaction
            yield buffers.delete(current_pid)
          end
        end
      end

      buffers.each_value do |buffer|
        yield buffer
      end
    end

    private

    def current_buffer
      buffers[current_pid]
    end

  end
end
