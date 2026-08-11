# frozen_string_literal: true

require "json"

module Qdrant
  class Client
    Response = Struct.new(:status, :headers, :body)

    class ResponseBuilder
      JSON_CONTENT_TYPE_REGEX = /\bjson\z/.freeze

      def initialize(response)
        @response = response
      end

      def build
        Response.new(
          status: @response.code.to_i,
          headers: @response.to_hash,
          body: parse_body
        )
      end

      private

      def parse_body
        body = @response.body
        return body unless !body.nil? && !body.empty? && json_response?

        JSON.parse(body)
      rescue JSON::ParserError
        # Fallback to raw body if JSON parsing fails unexpectedly
        body
      end

      def json_response?
        content_type = @response["Content-Type"]
        return false if content_type.nil?

        media_type = content_type.split(";").first.to_s.strip
        media_type.match?(JSON_CONTENT_TYPE_REGEX)
      end
    end
  end
end
