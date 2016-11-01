# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'googlemaps/services/version'

Gem::Specification.new do |spec|
  spec.name          = 'googlemaps-services'
  spec.version       = GoogleMaps::Services::VERSION
  spec.authors       = ['Faissal Elamraoui']
  spec.email         = ['amr.faissal@gmail.com']

  spec.summary       = %q{Ruby Client library for Google Maps API Web Services}
  spec.description   = %q{This library brings the Google Maps API Web Services to your Ruby/RoR application. It supports both JSON and XML response formats.}
  spec.homepage      = 'https://amrfaissal.github.io/googlemaps-services'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'nokogiri', '~> 1.6', '>= 1.6.8'
  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
end
