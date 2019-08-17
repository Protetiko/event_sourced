# frozen_string_literal: true

require 'event_sourced/command'

module EventSourced
  class TakeSnapshot < EventSourced::Command
  end
end

class SnapshotCommandHandler
  include EventSourced::CommandHandler

  on TakeSnapshot do |command|
    # load aggregate from command.aggregate_id
    # force aggregate to snapshot
  end
end
