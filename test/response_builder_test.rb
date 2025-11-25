# frozen_string_literal: true

require "test_helper"

class ResponseBuilderTest < Minitest::Test
  def test_builds_allow_response_with_original_input
    decision = {behavior: :allow}
    original_input = {command: "echo hello"}

    response = McpPermissionPrompt::ResponseBuilder.build(decision, original_input)

    assert_equal "allow", response[:behavior]
    assert_equal original_input, response[:updatedInput]
  end

  def test_builds_allow_response_with_updated_input
    decision = {behavior: :allow, updated_input: {command: "echo sanitized"}}
    original_input = {command: "echo hello --force"}

    response = McpPermissionPrompt::ResponseBuilder.build(decision, original_input)

    assert_equal "allow", response[:behavior]
    assert_equal({command: "echo sanitized"}, response[:updatedInput])
  end

  def test_builds_deny_response_with_reason
    decision = {behavior: :deny, reason: "Dangerous command blocked"}
    original_input = {command: "rm -rf /"}

    response = McpPermissionPrompt::ResponseBuilder.build(decision, original_input)

    assert_equal "deny", response[:behavior]
    assert_equal "Dangerous command blocked", response[:message]
  end

  def test_builds_deny_response_with_default_message
    decision = {behavior: :deny}
    original_input = {file_path: "/etc/passwd"}

    response = McpPermissionPrompt::ResponseBuilder.build(decision, original_input)

    assert_equal "deny", response[:behavior]
    assert_equal "Policy denied", response[:message]
  end

  def test_converts_symbol_behavior_to_string
    allow_decision = {behavior: :allow}
    deny_decision = {behavior: :deny, reason: "Test"}

    allow_response = McpPermissionPrompt::ResponseBuilder.build(allow_decision, {})
    deny_response = McpPermissionPrompt::ResponseBuilder.build(deny_decision, {})

    assert_equal "allow", allow_response[:behavior]
    assert_equal "deny", deny_response[:behavior]
  end

  def test_allow_response_includes_updated_input_key
    decision = {behavior: :allow}
    original_input = {test: "value"}

    response = McpPermissionPrompt::ResponseBuilder.build(decision, original_input)

    assert response.key?(:updatedInput)
    refute response.key?(:message)
  end

  def test_deny_response_includes_message_key
    decision = {behavior: :deny, reason: "blocked"}
    original_input = {test: "value"}

    response = McpPermissionPrompt::ResponseBuilder.build(decision, original_input)

    assert response.key?(:message)
    refute response.key?(:updatedInput)
  end
end
