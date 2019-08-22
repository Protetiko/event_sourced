# frozen_string_literal: true

require 'event_sourced/cache_backends/null_backend'

module EventSourced
  class Configuration
    attr_accessor :cache_backend
    attr_accessor :logger

    def initialize
      @cache_backend = EventSourced::CacheBackends::NullCache
      @logger        = ::Logger.new(STDOUT)
    end
  end
end
