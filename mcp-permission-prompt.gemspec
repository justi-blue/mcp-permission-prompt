# frozen_string_literal: true

require_relative "lib/mcp_permission_prompt/version"

Gem::Specification.new do |spec|
  spec.name = "mcp-permission-prompt"
  spec.version = McpPermissionPrompt::VERSION
  spec.authors = ["Justyna"]
  spec.email = ["justine84@gmail.com"]

  spec.summary = "Permission prompt handler for Claude Code CLI --permission-prompt-tool"
  spec.description = "First Ruby implementation of --permission-prompt-tool for Claude Code CLI. " \
                     "Handles permission prompts in headless mode (-p) with configurable policies. " \
                     "Compatible with official MCP Ruby SDK and fast-mcp."
  spec.homepage = "https://github.com/justi-blue/mcp-permission-prompt"
  spec.license = "MIT"
  spec.required_ruby_version = "~> 3.2"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => spec.homepage,
    "changelog_uri" => "#{spec.homepage}/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "#{spec.homepage}/issues",
    "documentation_uri" => "#{spec.homepage}#readme",
    "rubygems_mfa_required" => "true"
  }

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .github/ .standard.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Core dependency - autoloading
  spec.add_dependency "zeitwerk", "~> 2.6"

  # Optional MCP adapters (users install what they need)
  # spec.add_dependency "mcp", "~> 0.1"      # Official MCP Ruby SDK
  # spec.add_dependency "fast-mcp", "~> 1.5"  # fast-mcp alternative
end
