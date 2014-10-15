module Logtool
  class Parser
    attr_reader :filenames

    def initialize(filenames)
      @filenames = Array(filenames)
      @filenames << nil if @filenames.empty?  # will be interpreted as stdin
    end

    def run
      filenames.each do |filename|
        debug "parser: started #{filename} at #{Time.now}"
        Logtool::Input.new(filename).each do |line|
          yield line
        end
      end
      debug "parser: finished at #{Time.now}"
    end

    def debug(message)
      $stderr.puts message if ENV['DEBUG']
    end
  end
end
