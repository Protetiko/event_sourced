# frozen_string_literal: true

require 'json'

module EventSourced
  class MemoryRepository
    include EventSourced::Repository

    def initialize
      @store = {}
    end

    def append(record)
      aggregate_id = record.aggregate_id
      if store[aggregate_id]
        store[aggregate_id] << record
      else
        store[aggregate_id] = [record]
      end
    end

    def append_many(records)
      if records.is_a? Array
        records.each {|e| append(e) }
      elsif records.is_a? Hash
        append(records)
      end
    end

    def stream(aggregate_id)
      store[aggregate_id]
    end

    def dump
      store.each_pair do |key, records|
        puts "### #{key}".blue
        records.each do |record|
          puts JSON.pretty_generate record.to_h
        end
      end
    end

    private

    def store
      @store ||= {}
    end
  end
end
