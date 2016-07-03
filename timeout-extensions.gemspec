# coding: utf-8
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "timeout/extensions/version"

Gem::Specification.new do |spec|
  spec.name          = "timeout-extensions"
  spec.version       = Timeout::Extensions::VERSION
  spec.authors       = ["Tony Arcieri", "Tiago Cardoso"]
  spec.email         = ["bascule@gmail.com"]
  spec.summary       = "Extensions to the Ruby standard library's timeout API"
  spec.description   = "A timeout extension for Ruby which plugs into multiple timeout backends"
  spec.homepage      = "https://github.com/celluloid/timeout-extensions"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.0.0"
end
