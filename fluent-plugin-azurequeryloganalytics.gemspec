# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |gem|
  gem.name          = "fluent-plugin-azuremonitorlog"
  gem.version       = "0.0.1"
  gem.authors       = ["Nabil BOUILLIN"]
  gem.email         = ["nabil.bouillin@gmail.com"]
  gem.description   = %q{Input plugin for Azure Query Log Analytics.}
  gem.homepage      = "https://github.com/nabil-bouillin/fluent-plugin-azurequeryloganalytics"
  gem.summary       = gem.description
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency "fluentd", "~> 1.7.4"
  gem.add_dependency "ms_rest_azure", "~> 0.11.1"
  gem.add_dependency "oauth2", "~> 1.4.2"
  gem.add_development_dependency "rake", "~> 13.0.1"
  gem.add_development_dependency "test-unit", "~> 3.3.4"
  gem.license = 'MIT'
end
