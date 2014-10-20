require "spec_helper"

describe Logtool::Source do
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

    it "parses the input and yields each line to a block" do
      output_lines = []
      source.each do |line|
        output_lines << line
      end
      expect(output_lines.join).to eq input
    end
  end
end
