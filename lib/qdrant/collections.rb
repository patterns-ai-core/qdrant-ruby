# frozen_string_literal: true

module Qdrant
  class Collections < Base
    PATH = "collections"

    # Get list name of all existing collections
    def list
      response = client.connection.get(PATH)
      response.body
    end

    # Get detailed information about specified existing collection
    def get(collection_name:)
      response = client.connection.get("#{PATH}/#{collection_name}")
      response.body
    end

    # Create new collection with given parameters
    def create(
      collection_name:,
      vectors:,
      sparse_vectors: nil,
      shard_number: nil,
      replication_factor: nil,
      write_consistency_factor: nil,
      on_disk_payload: nil,
      hnsw_config: nil,
      wal_config: nil,
      optimizers_config: nil,
      init_from: nil,
      quantization_config: nil
    )
      response = client.connection.put("#{PATH}/#{collection_name}") do |req|
        req.body = {}
        req.body["vectors"] = vectors
        req.body["sparse_vectors"] = sparse_vectors unless sparse_vectors.nil?
        req.body["shard_number"] = shard_number unless shard_number.nil?
        req.body["replication_factor"] = replication_factor unless replication_factor.nil?
        req.body["write_consistency_factor"] = write_consistency_factor unless write_consistency_factor.nil?
        req.body["on_disk_payload"] = on_disk_payload unless on_disk_payload.nil?
        req.body["hnsw_config"] = hnsw_config unless hnsw_config.nil?
        req.body["wal_config"] = wal_config unless wal_config.nil?
        req.body["optimizers_config"] = optimizers_config unless optimizers_config.nil?
        req.body["init_from"] = init_from unless init_from.nil?
        req.body["quantization_config"] = quantization_config unless quantization_config.nil?
      end

      response.body
    end

    # Update parameters of the existing collection
    def update(
      collection_name:,
      optimizers_config: nil,
      params: nil
    )
      response = client.connection.patch("#{PATH}/#{collection_name}") do |req|
        req.body = {}
        req.body["optimizers_config"] = optimizers_config unless optimizers_config.nil?
        req.body["params"] = params unless params.nil?
      end

      response.body
    end

    # Drop collection and all associated data
    def delete(collection_name:)
      response = client.connection.delete("#{PATH}/#{collection_name}")
      response.body
    end

    # Get list of all aliases for a collection
    def aliases(collection_name:)
      response = client.connection.get("#{PATH}/#{collection_name}/aliases")
      response.body
    end

    # Update aliases of the collections
    def update_aliases(actions:)
      response = client.connection.post("#{PATH}/aliases") do |req|
        req.body = {
          actions: actions
        }
      end

      response.body
    end

    # Create index for field in collection.
    def create_index(
      collection_name:,
      field_name:,
      field_schema: nil,
      wait: nil,
      ordering: nil
    )
      response = client.connection.put("#{PATH}/#{collection_name}/index") do |req|
        req.params["ordering"] = ordering unless ordering.nil?
        # Add explicit false check to avoid nil case. True is default behavior.
        req.params["wait"] = wait unless wait.nil?
        req.body = {field_name: field_name}
        req.body["field_schema"] = field_schema unless field_schema.nil?
      end

      response.body
    end

    # Delete field index for collection
    def delete_index(
      collection_name:,
      field_name:
    )
      response = client.connection.delete("#{PATH}/#{collection_name}/index/#{field_name}")
      response.body
    end

    # Get cluster information for a collection
    def cluster_info(collection_name:)
      response = client.connection.get("#{PATH}/#{collection_name}/cluster")
      response.body
    end

    # Update collection cluster setup
    def update_cluster(
      collection_name:,
      move_shard:
    )
      response = client.connection.post("#{PATH}/#{collection_name}/cluster") do |req|
        req.body = {
          move_shard: move_shard
        }
      end
      response.body
    end

    # Download specified snapshot from a collection as a file
    def download_snapshot(
      collection_name:,
      snapshot_name:,
      filepath:
    )
      response = client.connection.get("#{PATH}/#{collection_name}/snapshots/#{snapshot_name}")
      File.open(File.expand_path(filepath), "wb+") { |fp| fp.write(response.body) }
    end

    # Delete snapshot for a collection
    def delete_snapshot(
      collection_name:,
      snapshot_name:
    )
      response = client.connection.delete("#{PATH}/#{collection_name}/snapshots/#{snapshot_name}")
      response.body
    end

    # Create new snapshot for a collection
    def create_snapshot(
      collection_name:
    )
      response = client.connection.post("#{PATH}/#{collection_name}/snapshots")
      response.body
    end

    # Get list of snapshots for a collection
    def list_snapshots(
      collection_name:
    )
      response = client.connection.get("collections/#{collection_name}/snapshots")
      response.body
    end

    # Recover local collection data from a snapshot. This will overwrite any data, stored on this node, for the collection. If collection does not exist - it will be created.
    def restore_snapshot(
      collection_name:,
      filepath:,
      priority: nil,
      wait: nil
    )
      response = client.connection.post("#{PATH}/#{collection_name}/snapshots/recover") do |req|
        req.params["wait"] = wait unless wait.nil?

        req.body = {
          location: filepath
        }
        req.body["priority"] = priority unless priority.nil?
      end
      response.body
    end
  end
end
