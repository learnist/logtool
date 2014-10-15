module Logtool
  class ResqueCollator < Collator

    def start_of_transaction?
      return true if current_line =~ /Started #perform/
      false
    end

    def handle_start_of_transaction
      # do nothing
    end

    def end_of_transaction?
      return true if current_line =~ /Completed #perform/
      false
    end

    def handle_end_of_transaction
      # do nothing
    end
  end
end
