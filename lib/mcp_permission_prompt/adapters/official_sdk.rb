# frozen_string_literal: true

require "json"

module McpPermissionPrompt
  module Adapters
    # Adapter for official MCP Ruby SDK (mcp gem)
    #
    # Usage in MCP server:
    #   class PermissionPromptHandler < McpPermissionPrompt::Adapters::OfficialSdk
    #     # Inherits description, input_schema, and call method
    #   end
    class OfficialSdk < ::MCP::Tool
      description "Handle permission prompts for Claude Code CLI in headless mode"

      input_schema(
        properties: {
          tool_name: {
            type: "string",
            description: "Tool name requesting permission (Bash, Write, Edit, etc.)"
          },
          input: {
            type: "object",
            description: "Tool input parameters to evaluate"
          }
        },
        required: ["tool_name", "input"]
      )

      def self.call(tool_name:, input:, server_context: nil)
        decision = McpPermissionPrompt.evaluate(tool_name, symbolize_keys(input))
        response_json = McpPermissionPrompt.build_response(decision, input)

        {
          content: [{type: "text", text: response_json.to_json}]
        }
      end

      def self.symbolize_keys(hash)
        return hash unless hash.is_a?(Hash)

        hash.each_with_object({}) do |(key, value), result|
          result[key.to_sym] = value.is_a?(Hash) ? symbolize_keys(value) : value
        end
      end
    end
  end
end
