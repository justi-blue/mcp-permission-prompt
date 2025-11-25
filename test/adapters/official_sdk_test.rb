# frozen_string_literal: true

require "test_helper"

# Mock MCP::Tool since we don't have mcp gem as dependency yet
module MCP
  class Tool
    def self.description(text)
      @description = text
    end

    def self.input_schema(schema)
      @input_schema = schema
    end
  end
end

require_relative "../../lib/mcp_permission_prompt/adapters/official_sdk"

class AdaptersOfficialSdkTest < Minitest::Test
  def test_inherits_from_mcp_tool
    assert McpPermissionPrompt::Adapters::OfficialSdk < MCP::Tool
  end

  def test_responds_to_call
    assert_respond_to McpPermissionPrompt::Adapters::OfficialSdk, :call
  end

  def test_call_returns_mcp_response_format
    result = McpPermissionPrompt::Adapters::OfficialSdk.call(
      tool_name: "Bash",
      input: {command: "echo hello"}
    )

    assert result.key?(:content)
    assert_equal 1, result[:content].length
    assert_equal "text", result[:content].first[:type]
  end

  def test_call_returns_allow_decision_for_safe_command
    result = McpPermissionPrompt::Adapters::OfficialSdk.call(
      tool_name: "Bash",
      input: {command: "echo hello"}
    )

    response = JSON.parse(result[:content].first[:text])
    assert_equal "allow", response["behavior"]
    assert response.key?("updatedInput")
  end

  def test_call_returns_deny_decision_for_dangerous_command
    McpPermissionPrompt.configure do |config|
      config.add_policy(McpPermissionPrompt::Policies::DangerousCommands.new)
    end

    result = McpPermissionPrompt::Adapters::OfficialSdk.call(
      tool_name: "Bash",
      input: {command: "rm -rf /tmp"}
    )

    response = JSON.parse(result[:content].first[:text])
    assert_equal "deny", response["behavior"]
    assert response.key?("message")

    McpPermissionPrompt.instance_variable_set(:@configuration, nil)
  end

  def test_symbolize_keys_converts_string_keys_to_symbols
    hash = {"command" => "test", "nested" => {"key" => "value"}}
    result = McpPermissionPrompt::Adapters::OfficialSdk.symbolize_keys(hash)

    assert_equal({command: "test", nested: {key: "value"}}, result)
  end

  def test_symbolize_keys_handles_already_symbolized_hash
    hash = {command: "test", nested: {key: "value"}}
    result = McpPermissionPrompt::Adapters::OfficialSdk.symbolize_keys(hash)

    assert_equal hash, result
  end

  def test_call_accepts_string_keys_in_input
    result = McpPermissionPrompt::Adapters::OfficialSdk.call(
      tool_name: "Bash",
      input: {"command" => "echo hello"}
    )

    response = JSON.parse(result[:content].first[:text])
    assert_equal "allow", response["behavior"]
  end
end
