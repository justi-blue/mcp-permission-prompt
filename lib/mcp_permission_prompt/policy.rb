# frozen_string_literal: true

module McpPermissionPrompt
  class Policy
    def self.evaluate(tool_name, input, policies)
      policies.each do |policy|
        decision = policy.evaluate(tool_name, input)
        return decision unless decision[:behavior] == :not_decided
      end

      # Default allow if no policy matched
      {behavior: :allow}
    end
  end
end
