require "spec_helper"

describe Logtool::RailsCollator do
  describe "for a typical input" do
    input = <<-INPUT.gsub(/^ {6}/, '')
      [2014-10-17T07:14:54.017] [25550] INFO <root> - Started GET "/foo" for 1.1.1.1 at 2014-10-17 07:14:54 +0000
      [2014-10-17T07:14:54.017] [25550] INFO <actioncontroller> - Completed 200 OK in 31.6ms (Views: 22.9ms | ActiveRecord: 1.6ms)
      [2014-10-17T07:14:54.017] [25551] INFO <root> - Started GET "/foo" for 2.2.2.2 at 2014-10-17 07:14:54 +0000
      [2014-10-17T07:14:54.017] [25551] FATAL <root> - RuntimeException:
        backtrace
        backtrace
      [2014-10-17T07:14:54.017] [25552] INFO <root> - Started GET "/foo" for 3.3.3.3 at 2014-10-17 07:14:54 +0000
      [2014-10-17T07:14:54.017] [25552] INFO <actioncontroller> - Completed 200 OK in 31.6ms (Views: 22.9ms | ActiveRecord: 1.6ms)
    INPUT

    let(:stringio) { StringIO.new(input) }
    let(:source)   { Logtool::Source.new(stringio) }
    let(:collator) { Logtool::RailsCollator.new(source) }

    it "parses the input and yields each line to a block" do
      output_buffers = []
      collator.run do |buffer|
        output_buffers << buffer.to_s
      end

      expect(output_buffers.size).to eq 3

      input_lines = input.split("\n").map{|line| line + "\n" }
      expect(output_buffers[0]).to eq input_lines[0..1].join
      expect(output_buffers[1]).to eq input_lines[6..7].join
      expect(output_buffers[2]).to eq input_lines[2..5].join

      # BUG: the buffer ordering enforced in the above assertions is actually wrong.
      # It would be nice to have the fatal error with stacktrace to appear before
      # the lines that come after it in the input.
    end
  end
end
