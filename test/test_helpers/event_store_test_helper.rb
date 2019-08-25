# frozen_string_literal: true

require 'test_helper'

class CompanyCreated < EventSourced::Event
  field :name
  field :industry

  builder do |data|
    self.name = data[:name]
    self.industry = data[:industry]
  end
end

class CreateCompany < EventSourced::Command
  field :name
  field :industry

  builder do |data|
    self.name = data[:name]
    self.industry = data[:industry]
  end
end

class EventStoreTest < MiniTest::Test
  def self.inherited(base)
    base.include(EventStoreTestCases)
    super(base)
  end

  def aggregate_id
    @aggregate_id ||= EventSourced::UUID.generate
  end

  def current_time()
    Time.now.utc.round(3)
  end

  module EventStoreTestCases
    COMMAND_KEYS = [
      :id,
      :aggregate_id,
      :aggregate_type,
      :type,
      :command_id,
      :correlation_id,
      :causation_id,
      :data,
      :meta_data,
      :timestamp,
    ]

    EVENT_KEYS = [
      :aggregate_id,
      :aggregate_type,
      :type,
      :command_id,
      :correlation_id,
      :causation_id,
      :data,
      :meta_data,
      :timestamp,
      :sequence_number,
    ]

    def teardown
      event_store.destroy_aggregate!(aggregate_id)
    end

    #
    # Test all interface methods are available
    #
    def test_interface
      assert event_store.respond_to? :create_aggregate
      assert event_store.respond_to? :read_aggregate
      assert event_store.respond_to? :update_aggregate
      assert event_store.respond_to? :save_snapshot
      assert event_store.respond_to? :read_snapshot
      assert event_store.respond_to? :read_last_snapshot
      assert event_store.respond_to? :append_command
      assert event_store.respond_to? :append_event
      assert event_store.respond_to? :append_events
      assert event_store.respond_to? :last_event
      assert event_store.respond_to? :event_stream
      assert event_store.respond_to? :destroy_all!
      assert event_store.respond_to? :destroy_aggregate!
    end

    def test_aggregate_interface
      aggregate_attributes = {
        id: aggregate_id,
        type: 'Company',
        created_at: current_time
      }

      event_store.create_aggregate(aggregate_attributes)
      aggregate = event_store.read_aggregate(aggregate_id)

      assert aggregate
      assert_instance_of Hash, aggregate
      assert_equal [:id, :type, :created_at].sort, aggregate.keys.sort
      assert_equal aggregate_attributes.sort, aggregate.sort

      snapshot_id = EventSourced::UUID.generate
      event_store.update_aggregate(aggregate_id, { last_snapshot_id: snapshot_id })
      aggregate = event_store.read_aggregate(aggregate_id)

      assert_equal [:id, :type, :created_at, :last_snapshot_id].sort, aggregate.keys.sort
      assert_equal aggregate_attributes.merge(last_snapshot_id: snapshot_id).sort, aggregate.sort
    end

    def test_missing_aggregate
      assert_raises EventSourced::EventStores::EventStore::AggregateRecordNotFound do
        event_store.read_aggregate(BSON::ObjectId.new.to_s)
      end
    end

    def test_snapshot_interface
      snapshot_attributes = {
        aggregate_id: aggregate_id,
        aggregate_type: 'Company',
        sequence_number: 10,
        data: {
          'name' => 'Protetiko',
          'industry' => 'Medtech',
        },
        created_at: current_time,
      }

      snapshot1 = event_store.save_snapshot(snapshot_attributes)
      snapshot_id = snapshot1[:id]

      assert snapshot1
      assert_equal snapshot_attributes.merge(id: snapshot_id).sort, snapshot1.sort

      snapshot2 = event_store.read_snapshot(snapshot_id)

      assert snapshot2
      assert_equal snapshot1.sort, snapshot2.sort

      snapshot_attributes2 = snapshot_attributes.merge(
        sequence_number: 11,
        data: {
          'name' => 'Protetiko',
          'industry' => 'Social media marketing'
        },
        created_at: current_time,
      )
      snapshot3 = event_store.save_snapshot(snapshot_attributes2)
      snapshot_id = snapshot3[:id]

      assert snapshot3
      assert_equal snapshot_attributes2.merge(id: snapshot_id).sort, snapshot3.sort

      snapshot4 = event_store.read_last_snapshot(aggregate_id)

      assert snapshot4
      assert_equal snapshot3.sort, snapshot4.sort
    end

    def test_command_interface
      command_attributes = {
        type:           'CreateCompany',
        aggregate_id:   aggregate_id,
        aggregate_type: 'Company',
        command_id:     EventSourced::UUID.generate,
        correlation_id: EventSourced::UUID.generate,
        causation_id:   EventSourced::UUID.generate,
        timestamp:      current_time,
        data: {
          "name" => "Protetiko",
          "industry" => "Medtech",
        },
        meta_data: {
          "user_id" => EventSourced::UUID.generate,
        },
      }

      command = CreateCompany.new(command_attributes)
      insert_count = event_store.append_command(command)
      assert 1, insert_count

      sleep(0.1)
      command = CreateCompany.new(command_attributes.merge(timestamp: current_time))
      insert_count = event_store.append_command(command)
      assert 1, insert_count

      commands = event_store.command_stream(aggregate_id)
      assert_kind_of Array, commands
      assert_equal 2, commands.size
      assert_kind_of Hash, commands.first
      assert_equal COMMAND_KEYS.sort, commands.first.keys.sort
      assert commands.first[:timestamp].to_f < commands.last[:timestamp].to_f
    end

    def test_event_interface
      event_attributes = {
        type:           'CompanyCreated',
        aggregate_id:   aggregate_id,
        aggregate_type: 'Company',
        command_id:     EventSourced::UUID.generate,
        correlation_id: EventSourced::UUID.generate,
        causation_id:   EventSourced::UUID.generate,
        timestamp:      current_time,
        data: {
          "name" => "Protetiko",
          "industry" => "Medtech",
        },
        meta_data: {
          "user_id" => EventSourced::UUID.generate,
        },
      }
      event = CompanyCreated.new(event_attributes)

      insert_count = event_store.append_event(event)
      assert 1, insert_count
      sleep(0.1)
      insert_count = event_store.append_event(event)
      assert 1, insert_count

      events = [ event ] * 3
      insert_count = event_store.append_events(events)
      assert 3, insert_count

      event = CompanyCreated.new(event_attributes.merge(timestamp: current_time))

      insert_count = event_store.append_event(event)
      assert_equal 1, insert_count
      events = event_store.event_stream(aggregate_id)

      assert events
      assert_kind_of Array, events
      assert_equal 6, events.count
      assert_equal EVENT_KEYS.sort, events.last.to_h.keys.sort
      assert events.first[:timestamp].to_f < events.last[:timestamp].to_f
    end
  end
end

