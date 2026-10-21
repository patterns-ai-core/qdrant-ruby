# frozen_string_literal: true

module Qdrant
  class Base
    attr_reader :client

    def initialize(client:)
      @client = client
    end

    private

    # Point the warning at the caller's code, skipping frames inside the gem and Forwardable.
    def deprecation_warning(message)
      uplevel = caller_locations.index { |loc| !loc.path.start_with?(__dir__) && !loc.path.end_with?("/forwardable.rb") }
      warn("[DEPRECATION] Qdrant: #{message}", uplevel: uplevel + 1)
    end
  end
end
