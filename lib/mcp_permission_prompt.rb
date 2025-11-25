# frozen_string_literal: true

require "zeitwerk"

module McpPermissionPrompt
  class Error < StandardError; end

  class << self
    def loader
      @loader ||= begin
        loader = Zeitwerk::Loader.for_gem
        loader.ignore("#{__dir__}/mcp_permission_prompt/adapters")
        loader.setup
        loader
      end
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def evaluate(tool_name, input)
      Policy.evaluate(tool_name, input, configuration.policies)
    end

    def build_response(decision, original_input)
      ResponseBuilder.build(decision, original_input)
    end
  end
end

McpPermissionPrompt.loader

# Auto-load adapters based on available gems
begin
  require "mcp"
  require_relative "mcp_permission_prompt/adapters/official_sdk"
rescue LoadError
end

begin
  require "fast_mcp"
  require_relative "mcp_permission_prompt/adapters/fast_mcp"
rescue LoadError
end
