# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'htot_conv/version'

Gem::Specification.new do |spec|
  spec.name          = "htot_conv"
  spec.version       = HTOTConv::VERSION
  spec.authors       = ["@cat_in_136"]
  spec.email         = ["cat.in.136+github@gmail.com"]

  spec.summary       = %q{Hierarchical-Tree Outline Text Converter}
  spec.description   = %q{Convert from a simple hierarchical-tree outline text into ugly xlsx file}
  spec.homepage      = "https://github.com/cat-in-136/htot_conv"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    #spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "axlsx", "~> 2.0.1"
  spec.add_dependency "rinne", "~> 0.0.3"

  spec.add_development_dependency "bundler", "~> 1.12"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "fakefs", "~> 0.11.3"
end
