# mcp-permission-prompt

Ruby gem implementing MCP-based permission handling for Claude Code CLI's `--permission-prompt-tool` flag.

## Status: Research & Documentation

**This gem is the first and only known working implementation of `--permission-prompt-tool` response format worldwide.**

After extensive global research across all major languages and platforms, no other functional implementation exists. However, the feature itself has **severely limited practical value** - Claude's intelligent tool selection bypasses the permission handler entirely (see Known Limitations).

## Features

- Configurable policy-based permission system
- Built-in policies: DangerousCommands, ProtectedPaths
- Adapter pattern for multiple MCP libraries (Official SDK, fast-mcp)
- Audit logging via decision callbacks
- Full input modification support
- Comprehensive test coverage (77 tests, 130 assertions)

## Installation

Add to your Gemfile:

```ruby
gem 'mcp-permission-prompt', git: 'https://github.com/justi-blue/mcp-permission-prompt'
```

Or install locally:

```ruby
gem 'mcp-permission-prompt', path: '../mcp-permission-prompt'
```

## Usage

### 1. Configure Policies

Create an initializer (e.g., `config/initializers/mcp_permission_prompt.rb`):

```ruby
require 'mcp_permission_prompt'

McpPermissionPrompt.configure do |config|
  # Add default policies
  config.add_policy(McpPermissionPrompt::Policies::DangerousCommands.new)
  config.add_policy(McpPermissionPrompt::Policies::ProtectedPaths.new)

  # Optional: Add decision callback for audit logging
  config.on_decision do |tool_name, input, decision|
    Rails.logger.info "[PermissionPrompt] #{tool_name}: #{decision[:behavior]} - #{decision[:reason] || 'allowed'}"
  end
end
```

### 2. Create MCP Tool Handler

```ruby
class PermissionPromptHandler < McpPermissionPrompt::Adapters::OfficialSdk
  # Inherits from adapter - no additional code needed
  # Policies configured in initializer will be automatically used
end
```

### 3. Register with MCP Server

```ruby
def self.all_tools
  [
    Mcp::Tools::PermissionPromptHandler,
    # ... other tools
  ]
end
```

### 4. Use with Claude CLI

```bash
claude --print "command here" \
  --permission-prompt-tool mcp__server_name__permission_prompt_handler
```

## Built-in Policies

### DangerousCommands

Blocks dangerous Bash commands:
- Destructive operations: `rm -rf`, `mkfs`, `dd`
- Remote code execution: `curl|bash`, `wget|sh`
- Privilege escalation: `chmod 777`, `chown -R`
- Fork bombs

### ProtectedPaths

Blocks writes to sensitive locations:
- System directories: `/etc`, `/usr`, `/var`
- Sensitive files: `.env`, credentials, SSH keys

## Custom Policies

```ruby
class MyCustomPolicy < McpPermissionPrompt::Policies::Base
  def evaluate(tool_name, input)
    return not_decided unless tool_name == "Bash"

    command = input[:command] || input["command"]
    return not_decided unless command

    if command.match?(/production/)
      deny("Production commands blocked in development")
    else
      not_decided
    end
  end
end

# Add to configuration
config.add_policy(MyCustomPolicy.new)
```

## Why This Feature Doesn't Work

**Critical Finding:** The `--permission-prompt-tool` handler is **never called** in practice because Claude intelligently avoids using tools that would trigger it.

### Empirical Test Results

When explicitly asked to use blocked commands:
- `rm -rf /tmp/test` → Claude uses `find` command instead
- `curl http://url` → Claude uses WebFetch (built-in tool)
- `git push` → Claude uses built-in Git client
- `rails test` → Claude uses MCP `test_runner` tool

**Handler was never invoked** despite being correctly registered and validated.

### Root Cause

Claude's AI system prioritizes alternative tools to accomplish tasks:
1. First checks static rules (`--allowedTools`/`--disallowedTools`)
2. If blocked, intelligently selects alternative built-in tools
3. Only calls `--permission-prompt-tool` when **no alternatives exist**
4. In practice, alternatives always exist for dangerous operations

### Additional Limitations

- **Headless only**: Works only with `-p` flag ([Issue #1429](https://github.com/anthropics/claude-code/issues/1429))
- **No documentation**: Zero working examples exist ([Issue #1175](https://github.com/anthropics/claude-code/issues/1175))
- **Global vacuum**: Extensive research found no functional implementations in any language

### Research Scope

Searched across:
- All major languages (English, Chinese, Russian, Japanese, Korean, Portuguese, Spanish, German)
- Platforms: GitHub, Stack Overflow, Hacker News, Reddit, official forums
- Result: **Zero working implementations globally**
- Only attempt: CLIAI/mcp_permission_server_claude_code (Python) - marked "WORK IN PROGRESS", non-functional

## Architecture

```
Configuration
  ├── Policies (chain of responsibility)
  │   ├── DangerousCommands
  │   ├── ProtectedPaths
  │   └── Custom policies
  ├── Callbacks (audit logging)
  └── Adapters
      ├── OfficialSdk (model_context_protocol gem)
      └── FastMcp (future support)
```

## Development

```bash
# Install dependencies
bundle install

# Run tests
bundle exec rake test

# Run with coverage
COVERAGE=true bundle exec rake test
```

## Research & Sources

### Documentation Issues
- [Issue #1175](https://github.com/anthropics/claude-code/issues/1175) - No minimal working example exists
- [Issue #1429](https://github.com/anthropics/claude-code/issues/1429) - Headless-only limitation
- [Issue #5631](https://github.com/anthropics/claude-code/issues/5631) - MCP tools bypass permissions
- [Issue #6625](https://github.com/anthropics/claude-code/issues/6625) - Slash commands bypass permissions

### Official Resources
- [Permission-Prompt-Tool Playbook](https://www.vibesparking.com/en/blog/ai/claude-code/docs/cli/2025-08-28-outsourcing-permissions-with-claude-code-permission-prompt-tool/) - Conceptual guide only
- [Headless Mode Docs](https://code.claude.com/docs/en/headless) - General headless usage
- [SDK Permissions](https://code.claude.com/docs/en/sdk/sdk-permissions) - Different feature (canUseTool callback)
- [Permission Model Guide](https://skywork.ai/blog/permission-model-claude-code-vs-code-jetbrains-cli/) - Static permissions overview

### Community Attempts
- [CLIAI/mcp_permission_server_claude_code](https://github.com/CLIAI/mcp_permission_server_claude_code) - Python implementation attempt, status: "WORK IN PROGRESS", non-functional
- [Hacker News - Docker skip-permissions](https://news.ycombinator.com/item?id=44956002) - Community uses `--dangerously-skip-permissions` workaround
- [Tools & System Prompt](https://gist.github.com/wong2/e0f34aac66caf890a332f7b6f9e2ba8f) - Built-in tools list (shows alternatives Claude uses)

## Contributing

Bug reports and pull requests are welcome at https://github.com/justi-blue/mcp-permission-prompt.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Acknowledgments

This gem implements the response format discovered through community research in [Issue #1175](https://github.com/anthropics/claude-code/issues/1175), as Anthropic's official documentation lacks working examples.
