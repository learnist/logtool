require "spec_helper"

describe Logtool::Command::Trace do
  input = <<-INPUT.gsub(/^ {6}/, '')
      [2014-10-17T07:14:54.017] [25550] INFO <root> - Started GET "/foo" for 1.1.1.1 at 2014-10-17 07:14:54 +0000
      [2014-10-17T07:14:54.017] [25550] INFO <actioncontroller> - current user: 1 (Alyssa P. Hacker, alyssa@example.com)
      [2014-10-17T07:14:54.017] [25550] INFO <actioncontroller> - Completed 200 OK in 31.6ms (Views: 22.9ms | ActiveRecord: 1.6ms)

      [2014-10-17T07:14:54.017] [25551] INFO <root> - Started GET "/foo" for 2.2.2.2 at 2014-10-17 07:14:54 +0000
      [2014-10-17T07:14:54.017] [25551] INFO <actioncontroller> - current user: 2 (Ben Bitdiddle, ben@example.com)
      [2014-10-17T07:14:54.017] [25551] INFO <actioncontroller> - Completed 200 OK in 31.6ms (Views: 22.9ms | ActiveRecord: 1.6ms)

      [2014-10-17T07:14:54.017] [25552] INFO <root> - Started GET "/foo" for 1.1.1.1 at 2014-10-17 07:14:54 +0000
      [2014-10-17T07:14:54.017] [25552] INFO <actioncontroller> - current user: 1 (Alyssa P. Hacker, alyssa@example.com)
      [2014-10-17T07:14:54.017] [25552] INFO <actioncontroller> - Completed 200 OK in 31.6ms (Views: 22.9ms | ActiveRecord: 1.6ms)

      [2014-10-17T07:14:54.017] [25551] INFO <root> - Started GET "/foo" for 2.2.2.2 at 2014-10-17 07:14:54 +0000
      [2014-10-17T07:14:54.017] [25551] INFO <actioncontroller> - current user: 3 (Louis Reasoner, louis@example.com)
      [2014-10-17T07:14:54.017] [25551] INFO <actioncontroller> - Completed 200 OK in 31.6ms (Views: 22.9ms | ActiveRecord: 1.6ms)
  INPUT

  let(:stringio) { StringIO.new(input) }
  let(:source)   { Logtool::Source.new(stringio) }
  let(:collator) { Logtool::RailsCollator.new(source) }
  let(:trace)    { Logtool::Command::Trace.new }

  describe "#trace_by_ip_address" do
    it "selects buffers according to the ip address of the client" do
      buffers = []  # TODO: make trace_by_ip_address return an array in the simple case?
      trace.trace_by_ip_address(collator, '1.1.1.1') do |buffer|
        buffers << buffer
      end

      input_chunks = input.split("\n\n")
      expect(buffers[0].to_s.chomp).to eq input_chunks[0]
      expect(buffers[1].to_s.chomp).to eq input_chunks[2]
      expect(buffers.length).to eq 2
    end
  end

  describe "#trace_by_user_id" do
    it "selects buffers according to the current user's id" do
      buffers = []
      trace.trace_by_user_id(collator, 2) do |buffer|
        buffers << buffer
      end

      input_chunks = input.split("\n\n")
      expect(buffers[0].to_s.chomp).to eq input_chunks[1]
      expect(buffers.length).to eq 1
    end
  end

  describe "#trace_by_email" do
    it "selects buffers according to the current user's email address" do
      buffers = []
      trace.trace_by_email(collator, 'louis@example.com') do |buffer|
        buffers << buffer
      end

      input_chunks = input.split("\n\n")
      expect(buffers[0].to_s.chomp).to eq input_chunks[3].chomp
      expect(buffers.length).to eq 1
    end
  end
end
