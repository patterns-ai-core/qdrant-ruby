# frozen_string_literal: true

require "spec_helper"

RSpec.describe Qdrant::Points do
  let(:client) {
    Qdrant::Client.new(
      url: "localhost:8080",
      api_key: "123"
    )
  }
  let(:points) { client.points }
  let(:point_fixture) { JSON.parse(File.read("spec/fixtures/point.json")) }
  let(:points_fixture) { JSON.parse(File.read("spec/fixtures/points.json")) }
  let(:status_response_fixture) { JSON.parse(File.read("spec/fixtures/status_response.json")) }

  describe "#upsert" do
    let(:response) {
      OpenStruct.new(body: status_response_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:put)
        .with('collections/test_collection/points')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.upsert(
        collection_name: "test_collection",
        points: [
          { id: 1, vector: [0.05, 0.61, 0.76, 0.74], payload: { city: "Berlin"} },
          { id: 2, vector: [0.19, 0.81, 0.75, 0.11], payload: { city: ["Berlin", "London"] } }
        ]
      )
      expect(response.dig('status')).to eq('ok')
    end
  end

  describe "#get" do
    let(:response) {
      OpenStruct.new(body: point_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with('collections/test_collection/points/1')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.get(
        collection_name: "test_collection",
        id: 1
      )
      expect(response.dig('result', 'id')).to eq(1)
    end
  end

  describe "#delete" do
    let(:response) {
      OpenStruct.new(body: status_response_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/delete')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.delete(
        collection_name: "test_collection",
        points: [3]
      )
      expect(response.dig('status')).to eq('ok')
    end
  end

  describe "#search" do
    let(:response) {
      OpenStruct.new(body: points_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/search')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.search(
        collection_name: "test_collection",
        vector: [0.05, 0.61, 0.76, 0.74],
        limit: 10
      )
      expect(response.dig('result').count).to eq(5)
    end
  end

  let(:count_response_fixture) { JSON.parse(File.read("spec/fixtures/count_points.json")) }

  describe "#count" do
    let(:response) {
      OpenStruct.new(body: count_response_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/count')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.count(
        collection_name: "test_collection"
      )
      expect(response.dig('result', 'count')).to eq(5)
    end
  end

  describe "#batch_search" do
    let(:response) {
      OpenStruct.new(body: points_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/search/batch')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.batch_search(
        collection_name: "test_collection",
        searches: [{
          vectors: [[0.05, 0.61, 0.76, 0.74], [0.19, 0.81, 0.75, 0.11]],
          limit: 10
        }]
      )
      expect(response.dig('result').count).to eq(5)
    end
  end

  describe "#recommend" do
    let(:response) {
      OpenStruct.new(body: points_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/recommend')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.recommend(
        collection_name: "test_collection",
        positive: [1, 2],
        limit: 5
      )
      expect(response.dig('result').count).to eq(5)
    end
  end

  describe "#batch_recommend" do
    let(:response) {
      OpenStruct.new(body: points_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/recommend/batch')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.batch_recommend(
        collection_name: "test_collection",
        searches: [{
          positive: [1, 2],
          limit: 5
        }]
      )
      expect(response.dig('result').count).to eq(5)
    end
  end

  describe "#scroll" do
    let(:response) {
      OpenStruct.new(body: points_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/scroll')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.scroll(
        collection_name: "test_collection",
        limit: 5
      )
      expect(response.dig('result').count).to eq(5)
    end
  end

  describe "#list" do
    let(:response) {
      OpenStruct.new(body: points_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.list(
        collection_name: "test_collection",
        ids: [4, 5, 1, 2, 6]
      )
      expect(response.dig('result').count).to eq(5)
    end
  end

  describe "#set_payload" do
    let(:response) {
      OpenStruct.new(body: status_response_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/payload')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.set_payload(
        collection_name: "test_collection",
        payload: {
          city: "Berlin"
        },
        points: [1]
      )
      expect(response.dig('status')).to eq('ok')
    end
  end

  describe "#clear_payload" do
    let(:response) {
      OpenStruct.new(body: status_response_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/payload/clear')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.clear_payload(
        collection_name: "test_collection",
        points: [1]
      )
      expect(response.dig('status')).to eq('ok')
    end
  end

  describe "#clear_payload_keys" do
    let(:response) {
      OpenStruct.new(body: status_response_fixture)
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with('collections/test_collection/points/payload/delete')
        .and_return(response)
    end

    it "return the data" do
      response = client.points.clear_payload_keys(
        collection_name: "test_collection",
        keys: ["city"],
        points: [1]
      )
      expect(response.dig('status')).to eq('ok')
    end
  end
end
