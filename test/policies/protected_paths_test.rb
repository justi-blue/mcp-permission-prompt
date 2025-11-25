# frozen_string_literal: true

require "test_helper"

class PoliciesProtectedPathsTest < Minitest::Test
  def setup
    @policy = McpPermissionPrompt::Policies::ProtectedPaths.new
  end

  def test_returns_not_decided_for_non_file_tools
    result = @policy.evaluate("Bash", {command: "echo hello"})

    assert_equal :not_decided, result[:behavior]
  end

  def test_returns_not_decided_when_file_path_missing
    result = @policy.evaluate("Write", {})

    assert_equal :not_decided, result[:behavior]
  end

  def test_returns_not_decided_for_safe_paths
    safe_paths = [
      "/tmp/test.txt",
      "/home/user/documents/file.txt",
      "app/config/settings.yml",
      "config/database.yml"
    ]

    safe_paths.each do |path|
      result = @policy.evaluate("Write", {file_path: path})
      assert_equal :not_decided, result[:behavior], "Expected safe path to return not_decided: #{path}"
    end
  end

  def test_blocks_write_to_etc_directory
    result = @policy.evaluate("Write", {file_path: "/etc/passwd"})

    assert_equal :deny, result[:behavior]
    assert_match %r{/etc/passwd}, result[:reason]
  end

  def test_blocks_write_to_usr_directory
    result = @policy.evaluate("Write", {file_path: "/usr/local/bin/script"})

    assert_equal :deny, result[:behavior]
    assert_match %r{/usr/local/bin/script}, result[:reason]
  end

  def test_blocks_write_to_var_directory
    result = @policy.evaluate("Write", {file_path: "/var/log/app.log"})

    assert_equal :deny, result[:behavior]
  end

  def test_blocks_write_to_root_directory
    result = @policy.evaluate("Write", {file_path: "/root/.bashrc"})

    assert_equal :deny, result[:behavior]
  end

  def test_blocks_env_files
    result = @policy.evaluate("Write", {file_path: "/app/.env"})

    assert_equal :deny, result[:behavior]
    assert_match(/\.env/, result[:reason])
  end

  def test_blocks_credentials_files
    result = @policy.evaluate("Write", {file_path: "/app/config/credentials.yml"})

    assert_equal :deny, result[:behavior]
    assert_match(/credentials/, result[:reason])
  end

  def test_blocks_secrets_files
    result = @policy.evaluate("Write", {file_path: "/app/config/secrets.yml"})

    assert_equal :deny, result[:behavior]
  end

  def test_blocks_password_files
    result = @policy.evaluate("Write", {file_path: "/app/passwords.txt"})

    assert_equal :deny, result[:behavior]
  end

  def test_blocks_ssh_keys
    result = @policy.evaluate("Write", {file_path: "/home/user/.ssh/id_rsa"})

    assert_equal :deny, result[:behavior]
    assert_match(/\.ssh/, result[:reason])
  end

  def test_blocks_edit_to_protected_paths
    result = @policy.evaluate("Edit", {file_path: "/etc/hosts"})

    assert_equal :deny, result[:behavior]
  end

  def test_handles_string_keys_in_input
    result = @policy.evaluate("Write", {"file_path" => "/etc/passwd"})

    assert_equal :deny, result[:behavior]
  end

  def test_case_insensitive_pattern_matching
    result = @policy.evaluate("Write", {file_path: "/ETC/passwd"})

    assert_equal :deny, result[:behavior]
  end

  def test_blocks_nested_env_files
    result = @policy.evaluate("Write", {file_path: "/app/config/.env.production"})

    assert_equal :deny, result[:behavior]
  end

  def test_blocks_credentials_in_path
    result = @policy.evaluate("Write", {file_path: "/app/my-credentials/data.json"})

    assert_equal :deny, result[:behavior]
  end

  def test_allows_read_tool
    result = @policy.evaluate("Read", {file_path: "/etc/passwd"})

    assert_equal :not_decided, result[:behavior]
  end
end
