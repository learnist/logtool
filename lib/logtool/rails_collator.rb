module Logtool
  class RailsCollator < Collator
    def start_of_transaction?(line, pid)
      return true if line =~ /INFO <root> - Started/
      return true if line =~ /INFO <actioncontroller> - Processing/ && !buffers.has_key?(pid)
      false
    end

    def end_of_transaction?(line)
      return true if line =~ /<actioncontroller> - Completed/
      return true if line =~ /<omniauth> - .* Request phase initiated/
      false
    end
  end
end
