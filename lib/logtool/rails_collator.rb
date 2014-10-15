module Logtool
  class RailsCollator < Collator
    attr_reader :pids_by_ip

    def initialize(*)
      @pids_by_ip = Hash.new {|h, k| h[k] = [] }
      super
    end

    def start_of_transaction?
      return true if current_line =~ /INFO <root> - Started/
      return true if current_line =~ /INFO <actioncontroller> - Processing/ && current_buffer.nil?  # omniauth case
      false
    end

    def handle_start_of_transaction
      if current_line =~ /INFO <root> - Started .* for (.*) at /
        ip_addr = current_buffer.ip_addr = $1

        active_pids = pids_by_ip[ip_addr]
        if active_pids.size > 0
          current_buffer.concurrent_pids = active_pids.map(&:to_i)
        end

        active_pids << current_pid
      end
    end

    def end_of_transaction?
      return true if current_line =~ /<actioncontroller> - Completed/
      return true if current_line =~ /<omniauth> - .* Request phase initiated/
      false
    end

    def handle_end_of_transaction
      pids_by_ip[current_buffer.ip_addr].delete(current_pid)
    end
  end
end
