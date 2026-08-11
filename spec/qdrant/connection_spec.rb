# frozen_string_literal: true

require "spec_helper"
require "socket"

RSpec.describe Qdrant::Client::Connection do
  # Spins up a one-shot stdlib TCP server that captures each raw request and
  # answers with the given scripted responses. Returns the port and a proc that
  # yields the list of captured requests.
  def with_server(responses, &block)
    server = TCPServer.new("127.0.0.1", 0)
    port = server.addr[1]
    requests = []

    thread = Thread.new do
      responses.each do |response|
        client = server.accept
        requests << read_http_request(client)
        client.write(build_response(response))
        client.close
      rescue Errno::ECONNRESET, Errno::EPIPE
        break
      end
    end

    begin
      yield port, proc { requests }
    ensure
      thread.join(5)
      server.close
    end
  end

  def read_http_request(client)
    request_line = client.gets
    headers = {}
    while (line = client.gets) && line != "\r\n"
      key, value = line.split(":", 2)
      headers[key.strip.downcase] = value.strip
    end
    body = nil
    length = headers["content-length"]&.to_i
    body = client.read(length) if length&.positive?
    {request_line: request_line, headers: headers, body: body}
  end

  def build_response(response)
    body = response[:body]
    "HTTP/1.1 #{response[:status]} #{response[:reason]}\r\n" \
      "Content-Type: #{response[:content_type]}\r\n" \
      "Content-Length: #{body.bytesize}\r\n" \
      "Connection: close\r\n\r\n" \
      "#{body}"
  end

  def connection(port, raise_error: false, api_key: nil, logger: Logger.new(File::NULL))
    Qdrant::Client::Connection.new(
      url: "http://127.0.0.1:#{port}",
      api_key: api_key,
      raise_error: raise_error,
      logger: logger
    )
  end

  describe "request transport" do
    it "POSTs params as a query string, JSON body and api-key header, and parses a JSON response" do
      with_server([{status: 200, reason: "OK", content_type: "application/json; charset=utf-8",
                    body: '{"status":"ok"}'}]) do |port, captured|
        conn = connection(port, api_key: "secret")

        response = conn.post("collections/points") do |req|
          req.params["wait"] = false
          req.body = {vector: [1]}
        end

        request = captured.call.first
        expect(request[:request_line]).to start_with("POST /collections/points?wait=false ")
        expect(request[:headers]["api-key"]).to eq("secret")
        expect(request[:headers]["content-type"]).to include("application/json")
        expect(request[:headers]["accept"]).to include("application/json")
        expect(JSON.parse(request[:body])).to eq("vector" => [1])

        expect(response.status).to eq(200)
        expect(response.body).to eq("status" => "ok")
      end
    end

    it "returns plain text verbatim and leaves binary snapshot bytes untouched" do
      metrics = "# TYPE qdrant_points_total counter\nqdrant_points_total 42"
      with_server([{status: 200, reason: "OK", content_type: "text/plain", body: metrics}]) do |port, _captured|
        expect(connection(port).get("metrics").body).to eq(metrics)
      end

      bytes = "\x00\x01\x02\xFF".b
      with_server([{status: 200, reason: "OK", content_type: "application/octet-stream",
                    body: bytes}]) do |port, _captured|
        expect(connection(port).get("snapshots/backup").body.b).to eq(bytes)
      end
    end

    it "preserves param ordering and false values, and merges an existing query string" do
      with_server([{status: 200, reason: "OK", content_type: "application/json", body: "{}"}]) do |port, captured|
        connection(port).put("collections/index") do |req|
          req.params["ordering"] = "weak"
          req.params["wait"] = false
        end
        expect(captured.call.first[:request_line]).to start_with("PUT /collections/index?ordering=weak&wait=false ")
      end

      with_server([{status: 200, reason: "OK", content_type: "application/json", body: "{}"}]) do |port, captured|
        connection(port).get("collections/points?existing=1") do |req|
          req.params["wait"] = false
        end
        expect(captured.call.first[:request_line]).to start_with("GET /collections/points?existing=1&wait=false ")
      end
    end

    it "returns status 400 and parsed body with raise_error false, and raises with raise_error true" do
      error_body = '{"status":{"error":"bad request"}}'
      responses = [
        {status: 400, reason: "Bad Request", content_type: "application/json", body: error_body},
        {status: 400, reason: "Bad Request", content_type: "application/json", body: error_body}
      ]

      with_server(responses) do |port, _captured|
        quiet = connection(port, raise_error: false)
        response = quiet.get("collections")
        expect(response.status).to eq(400)
        expect(response.body).to eq("status" => {"error" => "bad request"})

        loud = connection(port, raise_error: true)
        expect { loud.get("collections") }.to raise_error(Net::HTTPClientException)
      end
    end
  end

  describe "client configuration surface" do
    it "stores a custom adapter, memoizes the connection, and accepts a custom logger" do
      logger = Logger.new(File::NULL)
      client = Qdrant::Client.new(
        url: "http://127.0.0.1:1",
        adapter: :custom,
        logger: logger
      )

      expect(client.adapter).to eq(:custom)
      expect(client.logger).to eq(logger)
      expect(client.connection).to be_a(Qdrant::Client::Connection)
      expect(client.connection).to be(client.connection)
    end
  end
end
