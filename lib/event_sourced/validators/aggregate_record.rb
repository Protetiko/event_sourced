# frozen_string_literal: true

module EventSourced
  module Validators
    class AggregateRecord < Validators::Base
      set_validator(
        Dry::Validation.Params(Validators::BaseSchema) do
          required(:id).filled(:str?)
          required(:type).filled(:str?)
          required(:created_at) { filled? & (str? | time?) }
        end
      )
    end
  end
end
