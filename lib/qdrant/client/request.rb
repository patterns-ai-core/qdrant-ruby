# frozen_string_literal: true


module Qdrant
  class Client
    RequestData = Struct.new("Qdrant::Client::RequestData", :params, :body)

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
        Request.new build_uri, @verb, @request.body, @api_key
      end

      private

      def build_uri
        path, query = @path.split("?", 2)

        URI.parse(@base_url).tap do |uri|
          uri.path = File.join(uri.path.to_s, path)
          uri.query = URI.encode_www_form(
                        URI
                          .decode_www_form(query)
                          .concat(@request.params.transform_keys(&:to_s).to_a)
                      )
        end
      end
    end

    class Request
      def initialize(uri, verb, body, api_key, logger)
        logger.info("#{verb.to_s.upcase} #{uri}")
        @logger = logger

        @uri = uri
        @verb = verb
        @data = verb.new(uri.request_uri).tap do |r|
          if api_key
            r["api-key"] = api_key
          end

          if body
            r.body = JSON.generate(body)
            r["Content-Type"] = r["Accept"] = "application/json"
          end
        end

        logger.info("Request headers: #{redacted_headers.inspect}")
        logger.info("Request body: #{@request.body}") if @data.body
      end

      def perform(raise_error)
        @logger.info("Performing Request: #{@verb} #{@uri}")

        res = Net::HTTP.new(@uri.host, @uri.port) do |h|
          h.use_ssl = true if @uri.scheme == "https"
        end.request(@data)

        if raise_error
          res.value
        end
        
        @logger.info("Performing Request to #{@verb} #{@uri}: Status #{res.status}")

        res
      rescue StandardError => e
        @logger.error("#{@verb} #{@uri} failed: #{e.class}: #{e.message}")
        raise
      end

      private

      def redacted_headers
        @data.to_hash.tap do |h|
          h.merge("api-key" => "[FILTERED]") if h.key?("api-key")
        end
      end
    end
  end
end
