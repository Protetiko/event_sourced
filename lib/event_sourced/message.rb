# frozen_string_literal: true

require 'event_sourced/utils/attributes'
require 'event_sourced/utils/validation'

module EventSourced
  module Message
    module MessageBuilder
      module ClassMethods
        attr_reader :_builder

        def builder(&block)
          @_builder = block
        end
      end

      def self.included(base)
        base.extend(ClassMethods)
      end
    end

    def self.included(base)
      base.include(MessageValidation)
      base.include(MessageAttributes)
      base.include(MessageBuilder)
    end

    def to_json
      to_h.to_json
    end
  end
end
