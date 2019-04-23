# frozen_string_literal: true

module EventSourced
  module MessageHandler
    module ClassMethods
      def on(*messages, &block)
        messages.each do |message|
          message_map[message] ||= []
          message_map[message] << block
        end
      end

      def message_map
        @message_map ||= {}
      end

      def handles_message?(message)
        message_map.keys.include? message.class
      end

    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def handle_message(message)
      handlers = self.class.message_map[message.class]
      handlers.each {|handler| self.instance_exec(message, &handler) } if handlers
    end
  end
end
