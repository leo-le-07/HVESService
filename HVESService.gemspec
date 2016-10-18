# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'HVESService/version'

Gem::Specification.new do |spec|
  spec.name          = "HVESService"
  spec.version       = HVESService::VERSION
  spec.authors       = ["leo"]
  spec.email         = ["coder.leo.le@gmail.com"]

  spec.summary       = %q{Elastic search service for Hipvan project}
  spec.description   = %q{This gem is a bridge for interating with elastic search services so that other components can use}
  spec.homepage      = "https://github.com/leo-le-07/HVESService"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"

  # elasticsearch
  spec.add_dependency 'elasticsearch-ruby', '~> 0.0.4'
  spec.add_dependency 'elasticsearch-rails', '~> 0.1.9'
  spec.add_dependency 'elasticsearch-model', '~> 0.1.9'
end
