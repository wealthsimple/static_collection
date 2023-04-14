lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'static_collection/version'

Gem::Specification.new do |spec|
  spec.name = "static_collection"
  spec.version = StaticCollection::VERSION
  spec.authors = ["Peter Graham"]
  spec.email = ["peter@wealthsimple.com"]

  spec.summary = 'Run queries against static data.'
  spec.description = 'Rubygem for running basic queries against static data.'
  spec.homepage = "https://github.com/wealthsimple/static_collection"
  spec.license = "MIT"

  spec.required_ruby_version = '>= 3.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activesupport", ">= 4"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "rspec-its", "~> 1.2"
  spec.add_development_dependency "rubocop", "~> 1.2"
  spec.add_development_dependency "ws-style"
end
