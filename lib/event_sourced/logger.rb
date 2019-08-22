# frozen_string_literal: true

module EventSourced
  class Logger
    class << self
      attr_accessor :logger

      def method_missing(m, *args, &block)
        if logger && logger.respond_to?(m)
          logger.send(m, *args)
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        logger && logger.respond_to?(method_name)
      end
    end
  end
end