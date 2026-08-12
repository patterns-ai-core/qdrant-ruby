# frozen_string_literal: true

require "net/http"

require_relative "request"
require_relative "response"

module Qdrant
  class Client
    class Connection
      def initialize(url:, api_key:, raise_error:, logger:)
        @uri = url
        @api_key = api_key
        @raise_error = raise_error
        @logger = logger
      end

      def get(path, &block)
        execute(Net::HTTP::Get, path, &block)
      end

      def post(path, &block)
        execute(Net::HTTP::Post, path, &block)
      end

      def put(path, &block)
        execute(Net::HTTP::Put, path, &block)
      end

      def patch(path, &block)
        execute(Net::HTTP::Patch, path, &block)
      end

      def delete(path, &block)
        execute(Net::HTTP::Delete, path, &block)
      end

      private

      def execute(verb, path, &block)
        response = RequestBuilder
          .new(verb, @uri, path, @api_key, @logger)
          .tap(&block)
          .build
          .perform(@raise_error)

        ResponseBuilder.new(response).build
      end
    end
  end
end
