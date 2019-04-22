# frozen_string_literal: true

require_relative 'aggregate_root.rb'

module EventSourced
  class Projection
    include EventSourced::AggregateRoot
    include EventSourced::MessageAttributes
  end
end
