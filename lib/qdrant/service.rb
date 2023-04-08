# frozen_string_literal: true

module Qdrant
  class Service < Base
    # Collect telemetry data including app info, system info, collections info, cluster info, configs and statistics
    def telemetry(
      anonymize: nil
    )
      response = client.connection.get("telemetry") do |req|
        req.params["anonymize"] = anonymize if anonymize
      end
      response.body
    end

    # Collect metrics data including app info, collections info, cluster info and statistics
    def metrics(
      anonymize: nil
    )
      response = client.connection.get("metrics") do |req|
        req.params["anonymize"] = anonymize if anonymize
      end
      response.body
    end


    # Set lock options. If write is locked, all write operations and collection creation are forbidden. Returns previous lock options
    def set_lock(
      write:,
      error_message: nil
    )
      response = client.connection.post("locks") do |req|
        req.body = {
          write: write
        }
        req.body["error_message"] = error_message if error_message
      end
      response.body
    end

    # Get lock options. If write is locked, all write operations and collection creation are forbidden
    def locks
      response = client.connection.get("locks")
      response.body
    end
  end
end
