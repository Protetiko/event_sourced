# frozen_string_literal: true

module EventSourced
  module MessageAttributes
    module ClassMethods
      def field(name)
        define_method(name) do
          attributes[name]
        end

        define_method("#{name}=") do |val|
          attributes[name] = val
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def attributes
      @_attributes ||= {}
    end
  end
end
