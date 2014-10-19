module Logtool
  class Input
    attr_reader :stream

    def initialize(stream_or_filename = nil)
      @stream = case stream_or_filename
        when IO then stream_or_filename
        when nil, '-' then $stdin
        when /\.gz$/ then IO.popen("gunzip -c #{stream_or_filename}")
        when String then File.open(stream_or_filename)
        else
          raise ArgumentError, "invalid input type: #{stream_or_filename.class}"
      end
    end

    def each
      stream.each_line do |line|
        # Sanitize input data by stripping out invalid UTF-8 byte sequences, which can
        # appear in input when the client sends data in an encoding other than UTF-8.
        # If these values are passed through without first being sanitized, later
        # processing can blow up; in particular, regex matches will raise an error.
        # Thanks to http://stackoverflow.com/a/8873922/1090521 for this encoding trick.
        begin
          line =~ //
        rescue ArgumentError
          line.encode!('UTF-16', 'UTF-8', invalid: :replace, replace: '?')
          line.encode!('UTF-8', 'UTF-16')
        end

        yield line
      end
      stream.close unless stream == $stdin
    end
  end
end
