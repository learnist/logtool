Dir["#{File.dirname(__FILE__)}/*.rb"].each do |file|
  require file unless file == __FILE__
end
