# frozen_string_literal: true

require_relative 'aggregate_root.rb'

module EventSourced
  class Projection < EventSourced::AggregateRoot
    include EventSourced::MessageAttributes
  end
end
