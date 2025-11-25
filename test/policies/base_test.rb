# frozen_string_literal: true

require "test_helper"

class PoliciesBaseTest < Minitest::Test
  def setup
    @policy = McpPermissionPrompt::Policies::Base.new
  end

  def test_evaluate_returns_not_decided_by_default
    result = @policy.evaluate("Bash", {command: "test"})

    assert_equal :not_decided, result[:behavior]
  end

  def test_allow_returns_allow_decision_without_updated_input
    result = @policy.send(:allow)

    assert_equal :allow, result[:behavior]
    assert_nil result[:updated_input]
  end

  def test_allow_returns_allow_decision_with_updated_input
    updated = {command: "sanitized"}
    result = @policy.send(:allow, updated_input: updated)

    assert_equal :allow, result[:behavior]
    assert_equal updated, result[:updated_input]
  end

  def test_deny_returns_deny_decision_with_reason
    result = @policy.send(:deny, "Test reason")

    assert_equal :deny, result[:behavior]
    assert_equal "Test reason", result[:reason]
  end

  def test_not_decided_returns_not_decided_behavior
    result = @policy.send(:not_decided)

    assert_equal :not_decided, result[:behavior]
    assert_equal 1, result.keys.size
  end

  def test_subclass_can_override_evaluate
    custom_policy = Class.new(McpPermissionPrompt::Policies::Base) do
      def evaluate(tool_name, input)
        return deny("Blocked") if tool_name == "Bash"
        allow
      end
    end

    policy = custom_policy.new
    bash_result = policy.evaluate("Bash", {})
    write_result = policy.evaluate("Write", {})

    assert_equal :deny, bash_result[:behavior]
    assert_equal :allow, write_result[:behavior]
  end
end
