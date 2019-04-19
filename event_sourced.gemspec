
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "event_sourced/version"

Gem::Specification.new do |spec|
  spec.name          = "event_sourced"
  spec.version       = EventSourced::VERSION
  spec.authors       = ["David Sennerlöv"]
  spec.email         = ["david@protetiko.com"]

  spec.summary       = %q{Event sourcing library for ruby.}
  spec.homepage      = "http://protetiko.io"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
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

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency 'minitest-reporters', "~> 1.3.5"
  spec.add_development_dependency 'awesome_print', "~> 1.8.0"
  spec.add_development_dependency 'pry', "~> 0.12"

  spec.add_runtime_dependency "mongo", "~> 2.6.2"
  spec.add_runtime_dependency "dry-validation", "~> 0.12"
  spec.add_runtime_dependency "activesupport", "~> 5.2.1"
end
