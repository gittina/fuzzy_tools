# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "fuzzy/version"

Gem::Specification.new do |s|
  s.name        = "fuzzy"
  s.version     = Fuzzy::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Brian Hempel"]
  s.email       = ["plasticchicken@gmail.com"]
  s.homepage    = ""
  s.summary     = %q{High quality fuzzy search and string matching in Ruby.}
  s.description = %q{High quality fuzzy search and string matching in Ruby.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
  
  s.add_development_dependency 'bundler'
  s.add_development_dependency 'rspec'
end