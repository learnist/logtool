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
        # The following lines work around an annoyance in ruby's UTF-8 handling. Ruby strings are assumed
        # to be UTF-8 encoded by default; if a string happens to contain non-UTF-8 characters, various
        # things don't work, including regex matching. Regex matches against invalid UTF-8 characters will
        # produce "ArgumentError: invalid byte sequence in UTF-8". The following pair of conversions cleans
        # up the input string by translating from UTF-8 to UTF-16 and back again, with 'invalid' and
        # 'replace' options that specify how to handle invalid characters. (The fact that we use UTF-16
        # as the intermediate encoding is irrelevant. We could choose any encoding to be the intermediary.
        # The important thing is that the invalid/replace options take effect during the conversion.)
        # Thanks to http://stackoverflow.com/a/8873922/1090521 for this trick.
        line.encode!('UTF-16', 'UTF-8', invalid: :replace, replace: '')
        line.encode!('UTF-8', 'UTF-16')

        yield line
      end
      stream.close unless stream == $stdin
    end
  end
end
