lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "pludoni_rspec/version"

Gem::Specification.new do |spec|
  spec.name          = "pludoni_rspec"
  spec.version       = PludoniRspec::VERSION
  spec.authors       = ["Stefan Wienert"]
  spec.email         = ["info@stefanwienert.de"]

  spec.summary       = %{pludoni GmbH's RSpec template. Just require in spec_helper}
  spec.description   = %{pludoni GmbH's RSpec template. Just require in spec_helper}
  spec.homepage      = "https://github.com/pludoni/rspec_include"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # spec.add_dependency "vcr", ">= 3.0.0"
  # spec.add_dependency "geckodriver-helper", ">= 0.23.0"
  spec.add_dependency 'capybara', ">= 3.13.2"
  spec.add_dependency 'fuubar', '>= 2.3.1'
  spec.add_dependency 'headless', ">= 2.3.1"
  spec.add_dependency 'pry-rails'
  spec.add_dependency 'puma'
  spec.add_dependency 'cuprite'
  spec.add_dependency 'simplecov', ">= 0.16.1"
  spec.add_dependency "simplecov-cobertura"
  spec.add_dependency "rspec_junit_formatter"
  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 13.0"
end
