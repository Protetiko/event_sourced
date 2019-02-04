# frozen_string_literal: true

require 'test_helper'

class MockCommand
  include EventSourced::Command

  attr_reader :id, :params

  def initialize(id, params)
    @id = id
    @params = params
  end
end

class OtherMockCommand
  include EventSourced::Command

end

class MockCommandWithValidation
  include EventSourced::Command

  validator ->(){ true }
end

class MockCommandWithFailedValidation
  include EventSourced::Command

  validator ->(){ false }
end

class MockCommandHandler
  include EventSourced::CommandHandler

  on MockCommand do |c|
  end

  on OtherMockCommand do |c|
  end

  on MockCommandWithValidation do |c|
  end

  on MockCommandWithFailedValidation do |c|
  end
end

class CommandHandlerTest < MiniTest::Test
  let(:repository) { MockRepository.new }
  let(:command_handler) { MockCommandHandler.new(repository) }

  def test_it_handles_single_commands
    command_handler.handle_command(MockCommand.new("1", {a: 'b'}))
  end

  def test_it_handles_multiple_commands
    command_handler.handle_commands([MockCommand.new("1", {a: 'b'}), MockCommand.new("1", {a: 'c'}), OtherMockCommand.new])
  end

  def test_it_handle_commands_with_validation
    command_handler.handle_command(MockCommandWithValidation.new)

    assert_raises EventSourced::InvalidCommand do
      command_handler.handle_command(MockCommandWithFailedValidation.new)
    end
  end
end
