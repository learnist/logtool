module Logtool
  module Command
    class Resque

      def run(args)
        sources = args.map{|arg| Logtool::Source.new(arg) }
        Logtool::ResqueCollator.new(sources).run do |buffer|
          puts buffer.lines
          puts
        end
      end

    end
  end
end
