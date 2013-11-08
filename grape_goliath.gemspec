# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib) 
require 'grape_goliath/version'

Gem::Specification.new do |spec|
  spec.name          = "grape_goliath"
  spec.version       = GrapeGoliath::VERSION
  spec.authors       = ["manishaharidas"]
  spec.email         = ["manisha@qburst.com"]
  spec.summary       = %q{Grape+Goliath application generator gem}
  spec.description   = %q{grape_goliath is a gem which creates an application with tree structure specified for a Goliath application having Grape framework.}
  spec.homepage      = "http://github.com/qburstruby/grape_goliath"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = ["grape_goliath","gog"]
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.4.0.rc.1"
  spec.add_development_dependency "rake"
end
