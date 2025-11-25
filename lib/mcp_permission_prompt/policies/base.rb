# frozen_string_literal: true

module McpPermissionPrompt
  module Policies
    class Base
      def evaluate(tool_name, input)
        not_decided
      end

      protected

      def allow(updated_input: nil)
        {behavior: :allow, updated_input: updated_input}
      end

      def deny(reason)
        {behavior: :deny, reason: reason}
      end

      def not_decided
        {behavior: :not_decided}
      end
    end
  end
end
