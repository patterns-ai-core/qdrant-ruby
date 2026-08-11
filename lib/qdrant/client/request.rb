# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module Qdrant
  class Client
    RequestData = Struct.new(:params, :body)

    class RequestBuilder
      def initialize(verb, base_url, path, api_key, logger)
        raise ArgumentError, "unsupported HTTP verb" unless verb < Net::HTTPRequest

        @verb = verb
        @base_url = base_url
        @path = path
        @api_key = api_key
        @logger = logger

        @request = RequestData.new({}, nil)
      end

      def tap
        yield @request if block_given?
        self
      end

      def build
        Request.new build_uri, @verb, @request.body, @api_key, @logger
      end

      private

      def build_uri
        path, query = @path.to_s.split("?", 2)

        URI.join(@base_url, path).tap do |uri|
          if (query_pairs = URI.decode_www_form(query.to_s) + @request.params.to_a).any?
            uri.query = URI.encode_www_form(query_pairs)
          end
        end
      end
    end

    class Request
      def initialize(uri, verb, body, api_key, logger)
        @logger = logger
        @uri = uri
        @verb = verb

        @data = verb.new(uri.request_uri).tap do |request|
          request["api-key"] = api_key if api_key

          if body
            request.body = JSON.generate(body)
            request["Content-Type"] = request["Accept"] = "application/json"
          end
        end

        logger.info("#{verb_name} #{uri}")
        logger.info("Request headers: #{redacted_headers.inspect}")
        logger.info("Request body: #{@data.body}") if @data.body
      end

      def perform(raise_error)
        @logger.info("Performing Request: #{verb_name} #{@uri}")

        response = Net::HTTP.new(@uri.host, @uri.port).tap do |h|
          h.use_ssl = true if @uri.scheme == "https"
        end.request(@data)

        response.value if raise_error

        @logger.info("Response status: #{response.code}")
        response
      rescue => e
        @logger.error("#{verb_name} #{@uri} failed: #{e.class}: #{e.message}")
        raise
      end

      private

      def verb_name
        @verb.name.split("::").last.upcase
      end

      def redacted_headers
        @data.to_hash.tap do |headers|
          headers["api-key"] = "[FILTERED]" if headers.key?("api-key")
        end
      end
    end
  end
end
