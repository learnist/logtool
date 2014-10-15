module Logtool
  class Buffer
    attr_reader :lines

    def initialize
      @lines = []
    end

    def <<(line)
      @lines << line
    end
  end
end
