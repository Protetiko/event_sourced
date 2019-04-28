# frozen_string_literal: true

require 'securerandom'
require 'event_sourced/validators/command_validator'
require 'event_sourced/utils/uuid'
require 'event_sourced/utils/message_handler'

module EventSourced
  InvalidCommand = Class.new(StandardError)

  class CommandHandler
    include EventSourced::MessageHandler

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
      if Validators::CommandValidator.call(message).success?
        command = Command::Factory.build!(message.type, message)
        handle_command(command)
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
      @event_repository
    end

    def command_repository
      @command_repository
    end
  end
end
