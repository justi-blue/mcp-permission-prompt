# frozen_string_literal: true

require "test_helper"

class PolicyTest < Minitest::Test
  def test_returns_default_allow_when_no_policies
    decision = McpPermissionPrompt::Policy.evaluate("Bash", {command: "echo hello"}, [])

    assert_equal :allow, decision[:behavior]
  end

  def test_returns_first_non_not_decided_result
    policy1 = Minitest::Mock.new
    policy1.expect :evaluate, {behavior: :not_decided}, ["Bash", {command: "test"}]

    policy2 = Minitest::Mock.new
    policy2.expect :evaluate, {behavior: :deny, reason: "blocked"}, ["Bash", {command: "test"}]

    policy3 = Minitest::Mock.new

    decision = McpPermissionPrompt::Policy.evaluate("Bash", {command: "test"}, [policy1, policy2, policy3])

    assert_equal :deny, decision[:behavior]
    assert_equal "blocked", decision[:reason]
    policy1.verify
    policy2.verify
  end

  def test_skips_policies_after_first_match
    policy1 = Minitest::Mock.new
    policy1.expect :evaluate, {behavior: :allow}, ["Write", {file_path: "/tmp/test.txt"}]

    policy2 = Minitest::Mock.new

    decision = McpPermissionPrompt::Policy.evaluate("Write", {file_path: "/tmp/test.txt"}, [policy1, policy2])

    assert_equal :allow, decision[:behavior]
    policy1.verify
  end

  def test_returns_allow_when_all_policies_return_not_decided
    policy1 = Minitest::Mock.new
    policy1.expect :evaluate, {behavior: :not_decided}, ["Edit", {file_path: "test.rb"}]

    policy2 = Minitest::Mock.new
    policy2.expect :evaluate, {behavior: :not_decided}, ["Edit", {file_path: "test.rb"}]

    decision = McpPermissionPrompt::Policy.evaluate("Edit", {file_path: "test.rb"}, [policy1, policy2])

    assert_equal :allow, decision[:behavior]
    policy1.verify
    policy2.verify
  end

  def test_handles_allow_decision
    policy = Minitest::Mock.new
    policy.expect :evaluate, {behavior: :allow}, ["Read", {file_path: "README.md"}]

    decision = McpPermissionPrompt::Policy.evaluate("Read", {file_path: "README.md"}, [policy])

    assert_equal :allow, decision[:behavior]
    policy.verify
  end

  def test_handles_deny_decision_with_reason
    policy = Minitest::Mock.new
    policy.expect :evaluate, {behavior: :deny, reason: "Path blocked"}, ["Write", {file_path: "/etc/passwd"}]

    decision = McpPermissionPrompt::Policy.evaluate("Write", {file_path: "/etc/passwd"}, [policy])

    assert_equal :deny, decision[:behavior]
    assert_equal "Path blocked", decision[:reason]
    policy.verify
  end
end
