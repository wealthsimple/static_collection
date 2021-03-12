# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'static_collection/version'

Gem::Specification.new do |spec|
  spec.name          = "static_collection"
  spec.version       = StaticCollection::VERSION
  spec.authors       = ["Peter Graham"]
  spec.email         = ["peter@wealthsimple.com"]

  spec.summary       = %q{Run queries against static data.}
  spec.description   = %q{Rubygem for running basic queries against static data.}
  spec.homepage      = "https://github.com/wealthsimple/static_collection"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.metadata['allowed_push_host'] = "https://nexus.iad.w10external.com/repository/gems-private"

  spec.add_dependency "activesupport", ">= 4"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency "ws-gem_publisher", "~> 3"
end
