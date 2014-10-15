#!/usr/bin/env ruby
require File.expand_path File.dirname(__FILE__) + '/logtool/logtool.rb'

if i = ARGV.index('-o')
  ARGV.delete_at(i)
  output = Logtool::Output.new(ARGV.delete_at(i))
else
  output = Logtool::Output.new($stdout)
end

Logtool::TransactionCollator.new(ARGV).run do |buffer|
  output.puts buffer.lines.grep(/<root> - Started|<actioncontroller> - (Processing|Parameters|current user|rails session|user agent|Completed)|<omniauth>|FATAL/)
  output.puts
end
