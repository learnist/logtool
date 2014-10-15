module Logtool
  class ResqueCollator < Collator
    def start_of_transaction?(line, pid)
      return true if line =~ /Started #perform/
      false
    end

    def end_of_transaction?(line)
      return true if line =~ /Completed #perform/
      false
    end
  end
end
