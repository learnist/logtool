require 'fileutils'
require 'logging'

Dir["#{File.dirname(__FILE__)}/**/*.rb"].each do |filename|
  require filename unless filename == __FILE__
end

module Logtool
  # Applications should use this layout for log messages to ensure that logtool
  # will later be able to parse the necessary information back out of the logs.
  LAYOUT = Logging.layouts.pattern(pattern: '[%d] [%p] %l <%c> - %m\n', date_pattern: "%Y-%m-%dT%H:%M:%S")
end
