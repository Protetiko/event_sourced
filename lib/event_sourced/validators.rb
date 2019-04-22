# frozen_string_literal: true

require 'dry-validation'

module EventSourced
  module Validators
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

require 'event_sourced/validators/command_validator'
require 'event_sourced/validators/event_validator'
