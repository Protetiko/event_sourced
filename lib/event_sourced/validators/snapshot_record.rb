# frozen_string_literal: true

module EventSourced
  module Validators
    class SnapshotRecord < Validators::Base
      set_validator(
        Dry::Validation.Params(Validators::BaseSchema) do
          required(:aggregate_id).filled(:str?)
          required(:aggregate_type).filled(:str?)
          required(:sequence_number).filled(:int?)
          optional(:data).filled(:hash?)
          required(:created_at) { filled? & (str? | time?) }
        end
      )
    end
  end
end
