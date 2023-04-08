# frozen_string_literal: true

module Qdrant
  class Points < Base
    PATH = "points"

    # Lists all data objects in reverse order of creation. The data will be returned as an array of objects.
    def list(
      collection_name:,
      ids: nil,
      with_payload: nil,
      with_vector: nil,
      consistency: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}") do |req|
        req.params["consistency"] = consistency unless consistency.nil?

        req.body = {}
        req.body["ids"] = ids
        req.body["with_payload"] = with_payload unless with_payload.nil?
        req.body["with_vector"] = with_vector unless with_vector.nil?
      end
      response.body
    end

    # Perform insert + updates on points. If point with given ID already exists - it will be overwritten.
    def upsert(
      collection_name:,
      wait: nil,
      ordering: nil,
      batch: nil,
      points: nil
    )
      response = client.connection.put("collections/#{collection_name}/#{PATH}") do |req|
        req.params = {}
        req.params["wait"] = wait unless wait.nil?
        req.params["ordering"] = ordering unless ordering.nil?

        req.body = {}
        req.body["batch"] = batch unless batch.nil?
        req.body["points"] = points unless points.nil?
      end
      response.body
    end

    # Delete points
    def delete(
      collection_name:,
      wait: nil,
      ordering: nil,
      points:
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/delete") do |req|
        req.params["wait"] = wait unless wait.nil?
        req.params["ordering"] = ordering unless ordering.nil?

        req.body = {}
        req.body["points"] = points
      end
      response.body
    end

    # Retrieve full information of single point by id
    def get(
      collection_name:,
      id:,
      consistency: nil
    )
      response = client.connection.get("collections/#{collection_name}/#{PATH}/#{id}") do |req|
        req.params["consistency"] = consistency unless consistency.nil?
      end
      response.body
    end

    # Set payload values for points
    def set_payload(
      collection_name:,
      payload:,
      wait: nil,
      ordering: nil,
      points: nil,
      filter: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/payload") do |req|
        req.params["wait"] = wait unless wait.nil?
        req.params["ordering"] = ordering unless ordering.nil?

        req.body = {}
        req.body["payload"] = payload
        req.body["points"] = points unless points.nil?
        req.body["filter"] = filter unless filter.nil?
      end
      response.body
    end

    # Replace full payload of points with new one
    def overwrite_payload(
      collection_name:,
      wait: nil,
      ordering: nil,
      payload:,
      points: nil,
      filter: nil
    )
      response = client.connection.put("collections/#{collection_name}/#{PATH}/payload") do |req|
        req.params["wait"] = wait unless wait.nil?
        req.params["ordering"] = ordering unless ordering.nil?

        req.body = {}
        req.body["payload"] = payload
        req.body["points"] = points unless points.nil?
        req.body["filter"] = filter unless filter.nil?
      end
    end

    # Delete specified key payload for points
    def clear_payload_keys(
      collection_name:,
      wait: nil,
      ordering: nil,
      keys:,
      points: nil,
      filter: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/payload/delete") do |req|
        req.params["wait"] = wait unless wait.nil?
        req.params["ordering"] = ordering unless ordering.nil?

        req.body = {}
        req.body["keys"] = keys
        req.body["points"] = points unless points.nil?
        req.body["filter"] = filter unless filter.nil?        
      end
      response.body
    end

    # Remove all payload for specified points
    def clear_payload(
      collection_name:,
      wait: nil,
      ordering: nil,
      points: nil,
      filter: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/payload/clear") do |req|
        req.params["wait"] = wait unless wait.nil?
        req.params["ordering"] = ordering unless ordering.nil?

        req.body = {}
        req.body["points"] = points unless points.nil?
        req.body["filter"] = filter unless filter.nil?
      end
      response.body
    end

    # Scroll request - paginate over all points which matches given filtering condition
    def scroll(
      collection_name:,
      limit:,
      filter: nil,
      offset: nil,
      with_payload: nil,
      with_vector: nil,
      consistency: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/scroll") do |req|
        req.params["consistency"] = consistency unless consistency.nil?

        req.body = {}
        req.body["limit"] = limit
        req.body["filter"] = filter unless filter.nil?
        req.body["offset"] = offset unless offset.nil?
        req.body["with_payload"] = with_payload unless with_payload.nil?
        req.body["with_vector"] = with_vector unless with_vector.nil?
      end
      response.body
    end

    # Retrieve closest points based on vector similarity and given filtering conditions
    def search(
      collection_name:,
      vector:,
      limit:,
      filter: nil,
      params: nil,
      offset: nil,
      with_payload: nil,
      with_vector: nil,
      score_threshold: nil,
      consistency: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/search") do |req|
        req.params["consistency"] = consistency unless consistency.nil?

        req.body = {}
        req.body["vector"] = vector
        req.body["limit"] = limit
        req.body["filter"] = filter unless filter.nil?
        req.body["params"] = params unless params.nil?
        req.body["offset"] = offset unless offset.nil?
        req.body["with_payload"] = with_payload unless with_payload.nil?
        req.body["with_vector"] = with_vector unless with_vector.nil?
        req.body["score_threshold"] = score_threshold unless score_threshold.nil?
      end
      response.body
    end

    # Retrieve by batch the closest points based on vector similarity and given filtering conditions
    def batch_search(
      collection_name:,
      searches:,
      consistency: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/search/batch") do |req|
        req.params["consistency"] = consistency unless consistency.nil?

        req.body = {}
        req.body["searches"] = searches
      end
      response.body
    end

    # Look for the points which are closer to stored positive examples and at the same time further to negative examples.
    def recommend(
      collection_name:,
      positive:,
      limit:,
      negative: nil,
      filter: nil,
      params: nil,
      offset: nil,
      with_payload: nil,
      with_vector: nil,
      score_threshold: nil,
      using: nil,
      lookup_from: nil,
      consistency: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/recommend") do |req|
        req.params["consistency"] = consistency unless consistency.nil?

        req.body = {}
        req.body["positive"] = positive
        req.body["negative"] = negative unless negative.nil?
        req.body["limit"] = limit
        req.body["filter"] = filter unless filter.nil?
        req.body["params"] = params unless params.nil?
        req.body["offset"] = offset unless offset.nil?
        req.body["with_payload"] = with_payload unless with_payload.nil?
        req.body["with_vector"] = with_vector unless with_vector.nil?
        req.body["score_threshold"] = score_threshold unless score_threshold.nil?
        req.body["using"] = using unless using.nil?
        req.body["lookup_from"] = lookup_from unless lookup_from.nil?
      end
      response.body
    end

    # Look for the points which are closer to stored positive examples and at the same time further to negative examples.
    def batch_recommend(
      collection_name:,
      searches:,
      consistency: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/recommend/batch") do |req|
        req.params["consistency"] = consistency unless consistency.nil?

        req.body = {}
        req.body["searches"] = searches
      end
      response.body
    end

    # Count points which matches given filtering condition
    def count(
      collection_name:,
      filter: nil,
      exact: nil
    )
      response = client.connection.post("collections/#{collection_name}/#{PATH}/count") do |req|
        req.body = {}
        req.body["filter"] = filter unless filter.nil?
        req.body["exact"] = filter unless exact.nil?
      end
      response.body
    end
  end
end
