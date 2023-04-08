# frozen_string_literal: true

module Qdrant
  class Snapshots < Base
    PATH = "snapshots"

    # Get list of snapshots of the whole storage
    def list
      response = client.connection.get(PATH)
      response.body
    end

    # Create new snapshot of the whole storage
    def create
      response = client.connection.post(PATH)
      response.body
    end

    # Delete snapshot of the whole storage
    def delete(
      snapshot_name:
    )
      response = client.connection.delete("#{PATH}/#{snapshot_name}")
      response.body
    end

    # Download specified snapshot of the whole storage as a file
    def download(
      snapshot_name:,
      filepath:
    )
      response = client.connection.get("#{PATH}/#{snapshot_name}")
      File.open(File.expand_path(filepath), "wb+") { |fp| fp.write(response.body) }
    end
  end
end
