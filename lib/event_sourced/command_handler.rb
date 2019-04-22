# frozen_string_literal: true

require 'securerandom'
require 'event_sourced/validators/command_validator'
require 'event_sourced/utils/uuid'

module EventSourced
  InvalidCommand = Class.new(StandardError)

  module CommandHandler
    module ClassMethods
      def on(*commands, &block)
        commands.each do |command|
          command_map[command] ||= []
          command_map[command] << block
        end
      end

      def command_map
        @command_map ||= {}
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

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
        command = Command::Factory.build(message)
        handle_command(command)
      else
        raise InvalidCommand.new
      end
    end

    def handle(command)
      if handles_command?(command)
        raise InvalidCommand.new unless command.valid?

        handlers = self.class.command_map[command.class]
        handlers.each {|handler| self.instance_exec(command, &handler) } if handlers

        command_repository.append(command)
      end
    end

    def handle_commands(commands)
      commands.each do |command|
        handle(command)
      end
    end


    def handles_command?(command)
      self.class.command_map.keys.include? command.class
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
