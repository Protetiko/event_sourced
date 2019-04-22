# frozen_string_literal: true

module EventSourced
  module Validators
    EventValidator = Dry::Validation.Params(Validators::BaseSchema) do
      optional(:command_id).filled(:str?)
      required(:aggregate_id).filled(:str?)
      optional(:correlation_id).filled(:str?)
      required(:data).filled(:hash?)
      required(:meta_data).filled(:hash?)
      required(:timestamp).filled(:str?)
    end
  end
end
