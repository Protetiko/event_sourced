# frozen_string_literal: true

module EventSourced
  class Cache
    def initialize(backend = nil)
      @cache_backend = backend || EventSourced.configuration.cache_backend
    end

    Joiner = ->(namespace, key) { namespace ? "#{namespace}.#{key}" : key.to_s }

    def get(key, namespace: nil, &block)
      key = Joiner.call(namespace, key)

      return @cache_backend.get(key) if @cache_backend.key?(key)
      return nil unless block_given?

      result = yield(block)
      put(key, result) if result
      return result
    end

    def put(key, value, namespace: nil)
      key = Joiner.call(namespace, key)

      @cache_backend.put(key, value)
    end

    def delete(key)
      @cache_backend.delete(key)
    end
  end
end
