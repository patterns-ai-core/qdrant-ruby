# frozen_string_literal: true

class Qdrant
  class Client
    Response = Struct.new("Qdrant::Client::Response", :status, :headers, :body)

    class ResponseBuilder
      def initialize(response)
        @data = response
      end

      def build
        body = response.body
        body = JSON.parse(body) if json_media_type?(response["Content-Type"]) && !body.nil? && !body.empty?

        Response.new(response.code.to_i, response.to_hash, body)
      end

      private

      def json_media_type?(content_type)
        return false if content_type.nil?

        media_type = content_type.split(";").first.to_s.strip
        media_type =~ /\bjson\z/
      end
    end
  end
end
