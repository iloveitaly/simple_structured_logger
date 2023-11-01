# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = "simple_structured_logger"
  spec.version       = '1.0.2'
  spec.authors       = ["Michael Bianco"]
  spec.email         = ["mike@mikebian.co"]
  spec.licenses      = ['MIT']

  spec.summary       = "Simple structured logging with a simple codebase"
  spec.homepage      = "https://github.com/iloveitaly/simple_structured_logger"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_development_dependency "bundler", "~> 2.3.10"
  spec.add_development_dependency "rake", "~> 13.1.0"
  spec.add_development_dependency "minitest", "~> 5.16"
end
