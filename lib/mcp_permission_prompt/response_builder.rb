# frozen_string_literal: true

module McpPermissionPrompt
  class ResponseBuilder
    def self.build(decision, original_input)
      case decision[:behavior]
      when :allow
        {
          behavior: "allow",
          updatedInput: decision[:updated_input] || original_input
        }
      when :deny
        {
          behavior: "deny",
          message: decision[:reason] || "Policy denied"
        }
      end
    end
  end
end
