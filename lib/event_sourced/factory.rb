# frozen_string_literal: true

module EventSourced
  class Factory
    UndefinedFactoryTemplate = Class.new(StandardError)

    class << self
      def registry
        @factory_registry ||= {}
      end

      def build(type, data)
        klass = get_template(type)
        return klass && klass.new(data)
      end

      def build!(type, data)
        klass = get_template!(type)
        return klass.new(data)
      end

      def for(type)
        get_template(type)
      end

      def for!(type)
        get_template!(type)
      end

      def register(type, klass)
        registry[type] = klass
      end

      private

      def get_template(type)
        registry[type] || nil
      end

      def get_template!(type)
        get_template(type) || raise(UndefinedFactoryTemplate, "Undefined Factory Template for: #{type}")
      end
    end
  end
end
