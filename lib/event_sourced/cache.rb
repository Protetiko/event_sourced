# frozen_string_literal: true

module EventSourced
  class Cache
    def initialize(backend)
      @cache_backend = backend
    end

    def get(id, &block)
      return @cache_backend.get(id) if @cache_backend.key?(id)
      return nil unless block_given?

      result = yield(block)
      put(id, result) if result
      return result
    end

    def put(id, value)
      @cache_backend.put(id, value)
    end
  end
end