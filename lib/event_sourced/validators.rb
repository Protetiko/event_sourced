# frozen_string_literal: true

require 'dry-validation'

module EventSourced
  module Validators
    ValidationFailed = Class.new(StandardError)
    ValidatorNotSet = Class.new(StandardError)
    InvalidValidator = Class.new(StandardError)

    class Base
      module ClassMethods
        def set_validator(v)
          raise(InvalidValidator, 'Validator must respond to :call method') unless v.respond_to?(:call)
          @validator = v
        end

        def validator
          @validator || raise(ValidatorNotSet, "Internal validator not set for #{self.name}")
        end

        def valid?(message)
          validator.call(message).success?
        end

        def validate!(message)
          result = validator.call(message)
          raise(ValidationFailed, "#{self.name} failed validation: #{result.errors}") if result.failure?

          return result.output # return sanitized result
        end
      end

      def self.inherited(base)
        base.extend(ClassMethods)
      end
    end

    class BaseSchema < Dry::Validation::Schema
      configure do |_|
        def included_in_case_ignored?(list, input)
          list.any?{ |s| s.casecmp(input) == 0 }
        end

        def id?(value)
          value.class == String
        end
      end
    end
  end
end

require 'event_sourced/validators/command_message'
require 'event_sourced/validators/event_message'
require 'event_sourced/validators/snapshot_record'
require 'event_sourced/validators/aggregate_record'
