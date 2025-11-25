# frozen_string_literal: true

module McpPermissionPrompt
  class Configuration
    attr_reader :policies, :callbacks

    def initialize
      @policies = []
      @callbacks = {}
    end

    def add_policy(policy)
      @policies << policy
    end

    def on_decision(&block)
      @callbacks[:decision] = block
    end
  end
end
