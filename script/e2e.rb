# frozen_string_literal: true

require "bundler/setup"
require "logger"
require "securerandom"
require "qdrant"

def assert!(condition, message)
  raise "e2e assertion failed: #{message}" unless condition
end

def ok_body!(body, operation)
  assert!(body.is_a?(Hash), "#{operation} returned #{body.class}, expected Hash")
  assert!(body["status"] == "ok", "#{operation} returned status #{body["status"].inspect}")
  body
end

url = ENV.fetch("QDRANT_URL", "").strip
api_key = ENV.fetch("QDRANT_API_KEY", "").strip

abort "QDRANT_URL must be set to an https:// hosted endpoint" if url.empty? || !url.start_with?("https://")
abort "QDRANT_API_KEY must be set" if api_key.empty?

logger = Logger.new($stderr)
logger.level = Logger::WARN

client = Qdrant::Client.new(
  url: url,
  api_key: api_key,
  raise_error: true,
  logger: logger
)

collection_name = "qdrant_ruby_e2e_#{Process.pid}_#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_#{SecureRandom.hex(4)}"
collection_created = false
failure = nil

begin
  body = ok_body!(client.collections.list, "collections.list")
  assert!(body.dig("result", "collections").is_a?(Array), "collections.list result is not an Array")
  puts "e2e: connection and authentication passed"

  body = client.collections.create(
    collection_name: collection_name,
    vectors: {size: 3, distance: "Cosine"}
  )
  collection_created = true
  ok_body!(body, "collections.create")
  assert!(body["result"] == true, "collections.create did not return result=true")
  puts "e2e: collection created (#{collection_name})"

  body = ok_body!(client.collections.get(collection_name: collection_name), "collections.get")
  status = body.dig("result", "status")
  assert!(%w[green yellow].include?(status), "collection status was #{status.inspect}")

  points = [
    {id: 1, vector: [1.0, 0.0, 0.0], payload: {"source" => "hosted-e2e", "rank" => 1}},
    {id: 2, vector: [0.0, 1.0, 0.0], payload: {"source" => "hosted-e2e", "rank" => 2}}
  ]

  body = ok_body!(
    client.points.upsert(collection_name: collection_name, wait: true, points: points),
    "points.upsert"
  )
  assert!(body.dig("result", "status") == "completed", "points.upsert did not return a completed status")

  body = ok_body!(client.points.get(collection_name: collection_name, id: 1), "points.get")
  assert!(body.dig("result", "id") == 1, "points.get returned the wrong point")

  body = ok_body!(
    client.points.get_all(
      collection_name: collection_name,
      ids: [1, 2],
      with_payload: true,
      with_vector: true
    ),
    "points.get_all"
  )
  results = body.fetch("result")
  assert!(results.is_a?(Array) && results.length == 2, "points.get_all did not return two points")
  assert!(results.map { |point| point["id"] }.sort == [1, 2], "points.get_all returned unexpected IDs")
  assert!(results.find do |point|
    point["id"] == 1
  end.dig("payload", "source") == "hosted-e2e", "point payload was not persisted")
  puts "e2e: point write and read round trip passed"

  body = ok_body!(
    client.points.search(
      collection_name: collection_name,
      vector: [1.0, 0.0, 0.0],
      limit: 1,
      with_payload: true,
      with_vector: false
    ),
    "points.search"
  )
  hit = body.fetch("result").first
  assert!(hit && hit["id"] == 1, "points.search did not return point 1 first")
  assert!(hit["score"].to_f > 0.99, "points.search score was #{hit["score"].inspect}")

  body = ok_body!(client.points.count(collection_name: collection_name, exact: true), "points.count")
  assert!(body.dig("result", "count") == 2, "points.count did not return 2")
  puts "e2e: search and count passed"

  body = ok_body!(client.points.delete(collection_name: collection_name, points: [1, 2], wait: true), "points.delete")
  assert!(body.dig("result", "status") == "completed", "points.delete did not return a completed status")
  body = ok_body!(client.points.count(collection_name: collection_name, exact: true), "points.count after delete")
  assert!(body.dig("result", "count") == 0, "points.count after delete did not return 0")
  puts "e2e: point deletion passed"
rescue => e
  failure = e
  warn "e2e failed: #{e.class}: #{e.message}"
ensure
  if collection_created
    begin
      body = ok_body!(client.collections.delete(collection_name: collection_name), "collections.delete cleanup")
      assert!(body["result"] == true, "collections.delete cleanup did not return result=true")
      puts "e2e: temporary collection deleted"
    rescue => e
      failure ||= e
      warn "e2e cleanup failed: #{e.class}: #{e.message}"
    end
  end
end

if failure
  exit 1
else
  puts "e2e passed"
end
