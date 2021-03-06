# frozen_string_literal: true

require 'event_sourced/utils/uuid'
require 'event_sourced/utils/message_handler'

module EventSourced
  class CommandHandler
    include EventSourced::MessageHandler

    AggregateRootNotSet = Class.new(StandardError)
    InvalidCommand      = Class.new(StandardError)
    RepositoryNotSet    = Class.new(StandardError)
    UnhandledCommand    = Class.new(StandardError)

    def initialize(aggregate)
      @aggregate_root = aggregate
    end

    def handle_raw_command(message)
      raise InvalidCommand unless Validators::CommandMessage.valid?(message)

      command = Command::Factory.build!(message[:type], message)
      handle_message(command)
    end

    def handle(command)
      aggregate_root.load_and_yield(command.aggregate_id) do |aggregate|
        handle_message(command, aggregate)
      end

      repository.append_command(command)
    end

    def handle_commands(commands)
      commands.each do |command|
        handle(command)
      end
    end

    def aggregate_root
      @aggregate_root || raise(AggregateRootNotSet)
    end

    def repository
      aggregate_root.repository || raise(RepositoryNotSet)
    end
  end
end
