# frozen_string_literal: true

module EventSourced
  module MessageValidation
    module ClassMethods
      attr_accessor :_validator

      def validator(validator)
        if validator.respond_to?(:call)
          @_validator = validator
        end
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def valid?
      if self.class._validator
        self.class._validator.call
      else
        return true
      end
    end
  end
end
