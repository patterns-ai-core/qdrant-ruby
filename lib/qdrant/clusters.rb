# frozen_string_literal: true

module Qdrant
  class Clusters < Base
    PATH = "cluster"

    # Get information about the current state and composition of the cluster
    def info
      response = client.connection.get(PATH)
      response.body
    end

    # Tries to recover current peer Raft state.
    def recover
      response = client.connection.post("#{PATH}/recover")
      response.body
    end

    # Remove peer from the cluster
    def remove_peer(
      peer_id:,
      force: nil
    )
      response = client.connection.post("#{PATH}/recover") do |req|
        req.params['force'] = force if force
      end
      response.body
    end
  end
end
