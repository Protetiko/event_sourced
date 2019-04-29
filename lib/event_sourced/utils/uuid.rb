# frozen_string_literal: true

require 'securerandom'

module EventSourced
  module UUID
    extend self

    def generate
      SecureRandom.uuid
    end
  end
end
