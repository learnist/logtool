module Logtool
  module Command
    class Resque

      def run(args)
        Logtool::ResqueCollator.new(args).run do |buffer|
          puts buffer.lines
          puts
        end
      end

    end
  end
end
