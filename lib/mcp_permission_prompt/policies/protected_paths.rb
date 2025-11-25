# frozen_string_literal: true

module McpPermissionPrompt
  module Policies
    # Blocks writes to protected system paths and sensitive files.
    #
    # Patterns cover:
    # - System directories (/etc, /usr, /var, /root)
    # - Environment files (.env)
    # - Credentials and secrets
    # - SSH keys
    class ProtectedPaths < Base
      PROTECTED_PATTERNS = {
        system_directories: %r{^/(etc|usr|var|root)/}i,
        environment_files: /\.env/i,
        credentials: /(credentials|secrets|password)/i,
        ssh_keys: %r{\.ssh/}i
      }.freeze

      def evaluate(tool_name, input)
        return not_decided unless ["Write", "Edit"].include?(tool_name)

        file_path = input[:file_path] || input["file_path"]
        return not_decided unless file_path

        if PROTECTED_PATTERNS.values.any? { |pattern| file_path.match?(pattern) }
          deny("Write to protected path blocked: #{file_path}")
        else
          not_decided
        end
      end
    end
  end
end
