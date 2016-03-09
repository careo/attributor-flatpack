# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'attributor/flatpack/version'

Gem::Specification.new do |spec|
  spec.name = 'attributor-flatpack'
  spec.version = Attributor::Flatpack::VERSION
  spec.authors = ['Dane Jensen']
  spec.email = ['dane.jensen@gmail.com']

  spec.summary = 'Attributor type for loading configuration data'
  spec.homepage = 'https://github.com/careo/attributor-flatpack'
  spec.license = 'MIT'

  spec.files = `git ls-files -z`
               .split("\x0")
               .reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'attributor', '>= 5'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rspec-its'
  spec.add_development_dependency 'fuubar', '~> 2'
  spec.add_development_dependency 'guard'
  spec.add_development_dependency 'guard-rspec'
  spec.add_development_dependency 'guard-rubocop'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-byebug'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
