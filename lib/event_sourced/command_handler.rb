# frozen_string_literal: true

require 'event_sourced/utils/uuid'
require 'event_sourced/utils/message_handler'

module EventSourced
  class CommandHandler
    include EventSourced::MessageHandler

    InvalidCommand = Class.new(StandardError)
    RepositoryNotSet = Class.new(StandardError)

    def initialize(repository)
      @repository = repository
    end

    def apply(event)
      result = repository.append_event(event)
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
        handle_message(command)
        repository.append_command(command)
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

    def repository
      @repository || raise(RepositoryNotSet)
    end
  end
end
