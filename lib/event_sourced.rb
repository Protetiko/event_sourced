# frozen_string_literal: true

require 'active_support/core_ext/hash'
require 'event_sourced/version'
require 'event_sourced/configuration'
require 'event_sourced/logger'
require 'event_sourced/validators'
require 'event_sourced/cache'
require 'event_sourced/event'
require 'event_sourced/command'
require 'event_sourced/repository'
require 'event_sourced/command_handler'
require 'event_sourced/aggregate_root'
require 'event_sourced/projection'
require 'event_sourced/event_stores/memory_event_store'
require 'event_sourced/event_stores/mongo_event_store'

module EventSourced
  class << self
    def configure
      yield(configuration) if block_given?
    end

    def configuration
      @config ||= EventSourced::Configuration.new
    end
  end
end
