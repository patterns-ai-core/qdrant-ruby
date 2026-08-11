# frozen_string_literal: true

require "logger"
require "forwardable"

require_relative "client/connection"

module Qdrant
  class Client
    extend Forwardable

    attr_reader :url, :api_key, :adapter, :raise_error, :logger

    def_delegators :service, :telemetry, :metrics, :locks, :set_lock

    def initialize(
      url:,
      api_key: nil,
      raise_error: false,
      logger: nil,
      adapter: nil # Deprecated. Doesn't select the transport. Should be removed in subsequent releases
    )
      @url = normalize_url(url)
      @api_key = api_key
      @adapter = adapter
      @raise_error = raise_error
      @logger = logger || Logger.new($stdout)
    end

    def connection
      @connection ||= Connection.new(
        url: url,
        api_key: api_key,
        raise_error: raise_error,
        logger: logger
      )
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

    private

    def normalize_url(url)
      raise ArgumentError, "url needs to be string" unless url.is_a?(String)
      return url if url.start_with?("http://", "https://")

      "https://#{url}"
    end
  end
end
