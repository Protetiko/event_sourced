# frozen_string_literal: true

require 'event_sourced/utils/uuid'
require 'event_sourced/utils/message_handler'

module EventSourced
  class CommandHandler
    include EventSourced::MessageHandler

    InvalidCommand = Class.new(StandardError)
    EventRepositoryNotSet = Class.new(StandardError)
    CommandRepositoryNotSet = Class.new(StandardError)

    def initialize(event_repository, command_repository)
      @event_repository = event_repository
      @command_repository = command_repository
    end

    def apply(event)
      result = event_repository.append(event)
      if result
        return true
      else
        return false
      end
    end

    def handle_raw_command(message)
      if Validators::CommandMessage.valid?(message)
        command = Command::Factory.build!(message[:type], message)
        handle_message(command)
      else
        raise InvalidCommand.new
      end
    end

    def handle(command)
      if handles_command?(command)
        raise InvalidCommand.new unless command.valid?

        handle_message(command)

        command_repository.append(command)
      end
    end

    def handle_commands(commands)
      commands.each do |command|
        handle(command)
      end
    end


    def handles_command?(command)
      self.class.handles_message?(command)
    end

    private

    def event_repository
      @event_repository || raise(EventRepositoryNotSet)
    end

    def command_repository
      @command_repository || raise(CommandRepositoryNotSet)
    end
  end
end
