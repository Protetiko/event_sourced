# frozen_string_literal: true

require 'dry-validation'

module EventSourced
  module Validators
    EventValidator = Dry::Validation.Schema do
      required(:command_id).filled?(:str?)
      required(:aggregate_id).filled?(:str?)
      required(:command_type).filled?(:str?)
      required(:data).filled?(:str?)
      required(:meta_data).filled?(:str?)
      required(:created_at).filled?(:str?)
    end
  end
end
