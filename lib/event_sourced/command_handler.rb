# frozen_string_literal: true

require 'event_sourced/utils/uuid'
require 'event_sourced/utils/message_handler'

module EventSourced
  class CommandHandler
    include EventSourced::MessageHandler

    InvalidCommand = Class.new(StandardError)
    RepositoryNotSet = Class.new(StandardError)
    UnhandledCommand = Class.new(StandardError)

    def initialize(repository)
      @repository = repository
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
      raise(UnhandledCommand, command.to_json) unless handles_command?(command)

      handle_message(command)

      repository.append_command(command)
    end

    def handle_commands(commands)
      commands.each do |command|
        handle(command)
      end
    end


    def repository
      @repository || raise(RepositoryNotSet)
    end

    private

    def handles_command?(command)
      self.class.handles_message?(command)
    end
  end
end
