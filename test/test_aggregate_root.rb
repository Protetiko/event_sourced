# frozen_string_literal: true

require 'test_helper'

class MockEvent
  include EventSourced::Event

  attr_reader :id, :params

  def initialize(id, params)
    @id = id
    @params = params
  end
end

class OtherMockEvent
  include EventSourced::Event

end

class MockEventWithValidation
  include EventSourced::Event

  validator ->(){ true }
end

class MockEventWithFailedValidation
  include EventSourced::Event

  validator ->(){ false }
end

class MockEventHandler
  include EventSourced::EventHandler

  on MockEvent do |c|
  end

  on OtherMockEvent do |c|
  end

  on MockEventWithValidation do |c|
  end

  on MockEventWithFailedValidation do |c|
  end
end

class AggregateRootTest < MiniTest::Test
  let(:repository) { EventSourced::MemoryRepository.new }
  let(:aggregate_root) { MockCommandHandler.new(repository) }

  def test_it_handles_single_event
    aggregate_root.handle_event(MockEvent.new("1", {a: 'b'}))
  end

  def test_it_handles_multiple_events
    aggregate_root.handle_events([MockEvent.new("1", {a: 'b'}), MockEvent.new("1", {a: 'c'}), OtherMockEvent.new])
  end

  def test_it_handle_events_with_validation
    aggregate_root.handle_event(MockEventWithValidation.new)

    assert_raises EventSourced::Invalidevent do
      aggregate_root.handle_event(MockEventWithFailedValidation.new)
    end
  end
end
