# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'logtool/version'

Gem::Specification.new do |spec|
  spec.name          = "logtool"
  spec.version       = Logtool::VERSION
  spec.authors       = ["Jan Nelson"]
  spec.email         = ["jan@learnist.com"]
  spec.summary       = "A suite of tools for parsing Rails and Resque logs and producing various reports"
  spec.description   = ""
  spec.homepage      = "http://github.com/learnist/logtool"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "logging"

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
