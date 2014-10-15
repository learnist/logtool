Dir["#{File.dirname(__FILE__)}/**/*.rb"].each do |filename|
  require filename unless filename == __FILE__
end
