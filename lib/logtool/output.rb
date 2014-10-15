module Logtool
  class Output
    attr_reader :stream

    def initialize(stream_or_filename = nil)
      @stream = case stream_or_filename
        when IO then stream_or_filename
        when nil, '-' then $stdout
        when /\.gz$/ then IO.popen("gzip -c > #{stream_or_filename}", 'w')
        when String then File.open(stream_or_filename, 'w')
        else
          raise ArgumentError, "invalid output type: #{stream_or_filename.class}"
      end
    end

    def method_missing(method, *args)
      stream.send(method, *args)
    end
  end
end
