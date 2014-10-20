module Logtool
  class Buffer
    attr_reader :pid, :lines
    attr_accessor :ip_addr, :concurrent_pids

    def initialize(pid)
      @pid = pid
      @lines = []
    end

    def <<(line)
      lines << line
    end

    def to_s
      lines.join
    end
  end
end
