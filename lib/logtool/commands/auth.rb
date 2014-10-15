#!/usr/bin/env ruby
require File.expand_path File.dirname(__FILE__) + '/logtool/logtool.rb'

if i = ARGV.index('-o')
  ARGV.delete_at(i)
  output = Logtool::Output.new(ARGV.delete_at(i))
else
  output = Logtool::Output.new($stdout)
end

Logtool::TransactionCollator.new(ARGV).run do |buffer|
  if buffer.lines[0] =~ %r{/v3/auth/twitter(/callback)?\b} ||
      buffer.lines[1] =~ /V3::AuthController#(login|logout|signup)/
    output.puts buffer.lines
    output.puts
  end
end
