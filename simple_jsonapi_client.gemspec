# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "simple_jsonapi_client/version"

Gem::Specification.new do |spec|
  spec.name          = "simple_jsonapi_client"
  spec.version       = SimpleJSONAPIClient::VERSION
  spec.authors       = ["Ariel Caplan"]
  spec.email         = ["arielmcaplan@gmail.com"]

  spec.summary       = %q{Framework for writing clients for JSONAPI APIs in Ruby.}
  spec.homepage      = "https://github.com/amcaplan/simple_jsonapi_client"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 3.1.12"

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
