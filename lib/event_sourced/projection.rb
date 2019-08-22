# frozen_string_literal: true

require 'event_sourced/utils/message_handler'

module EventSourced
  class Projection < EventSourced::AggregateRoot
    include EventSourced::MessageHandler

    def apply(events)
      events = [events] unless events.is_a? Array

      events.each do |event|
        next unless self.class.handles_message?(event)

        handle_message(event)
      end
    end
  end
end

__END__

#example
SimpleOrder   = Struct.new(:id, :lab, :clinic, :patient)
SimplePatient = Struct.new(:id, :name, :age)
SimpleCompany = Struct.new(:id, :name, :type)

class SimpleOrderProjection < EventSourced::Projecti*on

  attr_reader :simple_order

  def initialize
    @simple_order = SimpleOrder.new
  end

  # This projection rejects/Ignore most events and only care about 4 types. The rest of
  # the event data is discarded for this use case.
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
