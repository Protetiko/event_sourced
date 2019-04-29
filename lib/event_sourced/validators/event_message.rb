# frozen_string_literal: true

module EventSourced
  module Validators
    class EventMessage < Validators::Base
      set_validator(
        Dry::Validation.Params(Validators::BaseSchema) do
          required(:aggregate_id).filled(:str?)
          optional(:command_id).filled(:str?)
          optional(:correlation_id).filled(:str?)
          optional(:causation_id).filled(:str?)
          optional(:data).filled(:hash?)
          optional(:meta_data).filled(:hash?)
          required(:timestamp).filled(:str?)
        end
      )
    end
  end
end