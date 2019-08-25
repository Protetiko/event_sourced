# frozen_string_literal: true

require 'event_sourced/utils/message_handler'

module EventSourced
  class Projection < EventSourced::AggregateRoot
    include EventSourced::MessageHandler

    MissmatchingAggregateId = Class.new(StandardError)
    IncorrectEventSequence  = Class.new(StandardError)

    attr_reader :aggregate_id
    attr_reader :sequence_number

    def apply(events)
      events = [events] unless events.is_a? Array

      @aggregate_id = events.first.aggregate_id unless @aggregate_id
      @sequence_number ||= 0

      events.each do |event|
        raise MissmatchingAggregateId, "Expected aggregate ID #{ @aggregate_id }, but got event with Aggregate ID #{ event.aggregate_id }" unless event.aggregate_id == @aggregate_id
        raise IncorrectEventSequence, "Expected event sequence number to be #{ @sequence_number + 1}, but got #{ event.sequence_number }" unless event.sequence_number == @sequence_number + 1

        handle_message(event)
        @sequence_number = event.sequence_number
      end

      return true # What is the failure case here?
    end

  end
end

__END__

#example
SimpleOrder   = Struct.new(:id, :lab, :clinic, :patient)
SimplePatient = Struct.new(:id, :name, :age)
SimpleCompany = Struct.new(:id, :name, :type)

# This projection rejects/Ignore most events and only care about 4 types. The rest of
# the event data is discarded for this use case.
class SimpleOrderProjection < EventSourced::Projection
  include EventSourced::Projection::Cachable

  attr_reader :simple_order

  def initialize
    @simple_order = SimpleOrder.new
  end

  on OrderCreated do |event|
    @simple_order.id = event.aggregate_id
  end

  on LabSet do |event|
    @simple_order.lab = SimpleCompany.new(event.data[:id], event.name, event.type).to_h
  end

  on ClinicSet do |event|
    @simple_order.clinic = SimpleCompany.new(event.id, event.name, event.type).to_h
  end

  on PatientSet do |event|
    @simple_order.patient = SimplePatient.new(event.patient_id, event.name, event.age).to_h
  end

  def to_h
    @simple_order.to_h
  end
end

##### Use case for projection inside order service:

projection = SimpleOrderProjection.load(aggregate_id) do |projection|
  # Partia or Full Cache miss, get event_stream and load
  events = OrderRepository.event_stream(aggregate_id, from: projection.sequence_number)
  projection.apply(events) if events.size > 0
  projection # This object will be stored in cache

  ##--- alt -- reload all events regardless if we have a partial hit

  events = OrderRepository.event_stream(aggregate_id, from: 0)
  projection = SimpleOrderProjection.new
  projection.apply(events) if events.size > 0
  projection # This object will be stored in cache
end



##### Use case in other service, reading events from queue

def self.handle(message)
  event = message.body

  projection = SimpleOrderProjection.load_and_apply(event.aggregate_id, event) do |projection|
    # full cache miss or partial cache hit, partial cache miss is the normal case
    #cache miss here: decide if it should be ignored or not
    # fetch event_stream from Order Service or raise exception
    events = OrderServiceAPIClient.get_event_stream(aggregate_id, from: projection.sequence_number, to: event.sequence_number)
    projection.apply(events) if events.size > 0
    projection
  end
end
