# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'event_sourced/version'

Gem::Specification.new do |spec|
  spec.name          = 'event_sourced'
  spec.version       = EventSourced::VERSION
  spec.authors       = ['David Sennerlöv']
  spec.email         = ['david@protetiko.com']

  spec.summary       = 'Event sourcing library for ruby.'
  spec.homepage      = 'http://protetiko.io'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'TODO: Set to "http://mygemserver.com"'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features|examples)/})
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) {|f| File.basename(f) }
  spec.require_paths = ['lib']


  spec.add_development_dependency 'amazing_print',      '~> 1'
  spec.add_development_dependency 'bundler',            '~> 2'
  spec.add_development_dependency 'minitest',           '~> 5'
  spec.add_development_dependency 'minitest-proveit',   '~> 1'
  spec.add_development_dependency 'minitest-reporters', '~> 1'
  spec.add_development_dependency 'pry',                '~> 0.13'
  spec.add_development_dependency 'rake',               '~> 13'

  spec.add_runtime_dependency 'activesupport',   '~> 6'
  spec.add_runtime_dependency 'activerecord',    '>= 6', '< 8'
  spec.add_runtime_dependency 'activemodel',     '~> 6'
  spec.add_runtime_dependency 'dry-validation',  '~> 1'
  spec.add_runtime_dependency 'mongo',           '~> 2'
  spec.add_runtime_dependency 'redis',           '~> 4'
  spec.add_runtime_dependency 'semantic_logger', '~> 4'
  spec.add_runtime_dependency 'zache',           '~> 0.12'
end
