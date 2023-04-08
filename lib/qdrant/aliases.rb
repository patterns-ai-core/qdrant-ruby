# frozen_string_literal: true

module Qdrant
  class Aliases < Base
    PATH = "aliases"

    # Get list of all aliases (for a collection)
    def list
      response = client.connection.get("aliases")
      response.body
    end
  end
end
