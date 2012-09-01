# -*- encoding: utf-8 -*-

$:.unshift File.expand_path("../lib", __FILE__)
require 'vanadiel/time'

Gem::Specification.new do |gem|
  gem.name          = "vanadiel-time"
  gem.version       = Vanadiel::Time::VERSION
  gem.summary       = %q{A library for dealing with Vana'diel time from Final Fantasy XI}
  gem.description   = %q{Converting between realtime and Vana'diel time, and so on.}
  gem.license       = "MIT"
  gem.authors       = ["Yuki"]
  gem.email         = "paselan@gmail.com"
  gem.homepage      = "https://github.com/pasela/vanadiel-time-gem"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'bundler', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 0.8'
  gem.add_development_dependency 'rspec', '~> 2.4'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'
  gem.add_development_dependency 'yard', '~> 0.8'
end
