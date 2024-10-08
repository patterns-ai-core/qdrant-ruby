# frozen_string_literal: true

require "faraday"
require "forwardable"

module Qdrant
  class Client
    extend Forwardable

    attr_reader :url, :api_key, :adapter, :raise_error, :logger

    def_delegators :service, :telemetry, :metrics, :locks, :set_lock

    def initialize(
      url:,
      api_key: nil,
      adapter: Faraday.default_adapter,
      raise_error: false,
      logger: nil
    )
      @url = url
      @api_key = api_key
      @adapter = adapter
      @raise_error = raise_error
      @logger = logger || Logger.new($stdout)
    end

    def connection
      @connection ||= Faraday.new(url: url) do |faraday|
        if api_key
          faraday.headers["api-key"] = api_key
        end
        faraday.request :json
        faraday.response :logger, @logger, {headers: true, bodies: true, errors: true}
        faraday.response :raise_error if raise_error
        faraday.response :json, content_type: /\bjson$/
        faraday.adapter adapter
      end
    end

    def aliases
      @aliases ||= Qdrant::Aliases.new(client: self).list
    end

    def collections
      @collections ||= Qdrant::Collections.new(client: self)
    end

    def snapshots
      @snapshots ||= Qdrant::Snapshots.new(client: self)
    end

    def service
      @service ||= Qdrant::Service.new(client: self)
    end

    def clusters
      @clusters ||= Qdrant::Clusters.new(client: self)
    end

    def points
      @points ||= Qdrant::Points.new(client: self)
    end
  end
end
