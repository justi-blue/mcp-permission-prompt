# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    @config = McpPermissionPrompt::Configuration.new
  end

  def test_initializes_with_empty_policies
    assert_equal [], @config.policies
  end

  def test_initializes_with_empty_callbacks
    assert_equal({}, @config.callbacks)
  end

  def test_add_policy_appends_to_policies_array
    policy = Object.new
    @config.add_policy(policy)

    assert_equal [policy], @config.policies
  end

  def test_add_policy_supports_multiple_policies
    policy1 = Object.new
    policy2 = Object.new

    @config.add_policy(policy1)
    @config.add_policy(policy2)

    assert_equal [policy1, policy2], @config.policies
  end

  def test_on_decision_stores_callback_block
    callback_executed = false
    @config.on_decision { callback_executed = true }

    refute_nil @config.callbacks[:decision]
    @config.callbacks[:decision].call
    assert callback_executed
  end

  def test_on_decision_replaces_previous_callback
    first_callback = -> { :first }
    second_callback = -> { :second }

    @config.on_decision(&first_callback)
    @config.on_decision(&second_callback)

    assert_equal :second, @config.callbacks[:decision].call
  end
end
