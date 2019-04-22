# frozen_string_literal: true

module EventSourced
  module Validators
    CommandValidator = Dry::Validation.Params(Validators::BaseSchema) do
      required(:aggregate_id).filled(:str?)
      optional(:command_id).filled(:str?)
      optional(:correlation_id).filled(:str?)
      required(:type).filled(:str?)
      required(:data).filled(:hash?)
      required(:meta_data).filled(:hash?)
      optional(:timestamp).filled(:date?)
    end
  end
end
