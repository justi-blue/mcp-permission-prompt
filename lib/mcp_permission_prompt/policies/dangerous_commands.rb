# frozen_string_literal: true

module McpPermissionPrompt
  module Policies
    # Blocks dangerous Bash commands that could destroy system or compromise security.
    #
    # Patterns cover:
    # - Filesystem destruction (rm -rf)
    # - Device manipulation (dd, mkfs, writes to /dev/sd*)
    # - Privilege escalation (recursive chown/chgrp, chmod 777)
    # - Remote code execution (curl/wget piped to shell)
    # - Fork bombs
    class DangerousCommands < Base
      DANGEROUS_PATTERNS = {
        destructive_remove: /rm\s+-r?f/i,
        format_filesystem: /mkfs/i,
        device_manipulation: /dd\s+(if=|of=)/i,
        piped_downloads: /(curl|wget).*\|\s*(bash|sh)/i,
        fork_bomb: /:\(\)\{ :\|:& \};:/,
        block_device_write: />\s*\/dev\/sd/i,
        insecure_permissions: /chmod\s+(-R\s+)?777/i,
        recursive_ownership: /(chown|chgrp)\s+-R.*\//i
      }.freeze

      def evaluate(tool_name, input)
        return not_decided unless tool_name == "Bash"

        command = input[:command] || input["command"]
        return not_decided unless command

        if DANGEROUS_PATTERNS.values.any? { |pattern| command.match?(pattern) }
          deny("Dangerous command blocked: #{command[0..50]}")
        else
          not_decided
        end
      end
    end
  end
end
