# frozen_string_literal: true

module EventSourced
  module Validators
    class CommandMessage < Validators::Base
      set_validator(
        Dry::Validation.Params(Validators::BaseSchema) do
          required(:aggregate_id).filled(:str?)
          optional(:command_id).filled(:str?)
          optional(:correlation_id).filled(:str?)
          required(:type).filled(:str?)
          optional(:data).filled(:hash?)
          optional(:meta_data).filled(:hash?)
          optional(:timestamp).filled(:date?)
        end
      )
    end
  end
end