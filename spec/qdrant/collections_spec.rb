# frozen_string_literal: true

require "spec_helper"

RSpec.describe Qdrant::Collections do
  let(:client) {
    Qdrant::Client.new(
      url: "localhost:8080",
      api_key: "123"
    )
  }
  let(:collections) { client.collections }
  let(:status_response_fixture) { JSON.parse(File.read("spec/fixtures/status_response.json")) }
  let(:collection_fixture) { JSON.parse(File.read("spec/fixtures/collection.json")) }
  let(:collections_fixture) { JSON.parse(File.read("spec/fixtures/collections.json")) }
  let(:aliases_fixture) { JSON.parse(File.read("spec/fixtures/aliases.json")) }

  describe "#list" do
    let(:response) { OpenStruct.new(body: collections_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with(Qdrant::Collections::PATH)
        .and_return(response)
    end

    it "returns collections" do
      expect(collections.list.dig('result', 'collections').count).to eq(1)
    end
  end

  describe "#get" do
    let(:response) { OpenStruct.new(body: collection_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("collections/test_collection")
        .and_return(response)
    end

    it "returns the collection" do
      response = collections.get(collection_name: "test_collection")
      expect(response.dig('result', 'status')).to eq('green')
    end
  end

  describe "#create" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:put)
        .with("collections/test_collection")
        .and_return(response)
    end

    it "returns the status" do
      response = collections.create(
        collection_name: "test_collection",
        vectors: {
          size: 4,
          distance: "Dot"
        }
      )
      expect(response.dig("status")).to eq("ok")
      expect(response.dig("result")).to eq(true)
    end
  end

  describe "#delete" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:delete)
        .with("collections/test_collection")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.delete(collection_name: "test_collection")
      expect(response.dig('status')).to eq('ok')
      expect(response.dig('result')).to eq(true)
    end
  end

  describe "#update" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:patch)
        .with("collections/test_collection")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.update(
        collection_name: "test_collection",
        params: {
          replication_factor: 1
        }
      )
      expect(response.dig('status')).to eq('ok')
      expect(response.dig('result')).to eq(true)
    end
  end

  describe "#update_aliases" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("collections/aliases")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.update_aliases(
        actions: [{
          create_alias: {
            collection_name: 'test_collection',
            alias_name: 'alias_test_collection'
          }
        }]
      )
      expect(response.dig('status')).to eq('ok')
      expect(response.dig('result')).to eq(true)
    end
  end

  describe "#aliases" do
    let(:response) { OpenStruct.new(body: aliases_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("collections/test_collection/aliases")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.aliases(collection_name: "test_collection")
      expect(response.dig('result', 'aliases').count).to eq(1)
    end
  end

  describe "#create_index" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:put)
        .with("collections/test_collection/index")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.create_index(
        collection_name: "test_collection",
        field_name: "description",
        field_schema: "text"
      )
      expect(response.dig('status')).to eq('ok')
      expect(response.dig('result')).to eq(true)
    end
  end

  describe "#delete_index" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:delete)
        .with("collections/test_collection/index/description")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.delete_index(
        collection_name: "test_collection",
        field_name: "description"
      )
      expect(response.dig('status')).to eq('ok')
      expect(response.dig('result')).to eq(true)
    end
  end

  describe "#cluster_info" do
    let(:response) { OpenStruct.new(body: JSON.parse(File.read("spec/fixtures/collection_cluster.json"))) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("collections/test_collection/cluster")
        .and_return(response)
    end

    it "returns the cluster info" do
      response = collections.cluster_info(
        collection_name: "test_collection"
      )
      expect(response.dig('result', 'peer_id')).to eq(111)
    end
  end

  describe "#update_cluster" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("collections/test_collection/cluster")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.update_cluster(
        collection_name: "test_collection",
        move_shard: {
            shard_id: 0,
            to_peer_id: 222,
            from_peer_id: 111
        }
      )
      expect(response.dig('status')).to eq('ok')
      expect(response.dig('result')).to eq(true)
    end
  end

  describe "#list_snapshots" do
    let(:response) { OpenStruct.new(body: JSON.parse(File.read("spec/fixtures/snapshots.json"))) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("collections/test_collection/snapshots")
        .and_return(response)
    end

    it "returns the cluster info" do
      response = collections.list_snapshots(
        collection_name: "test_collection"
      )
      expect(response.dig('result').count).to eq(2)
    end
  end

  let(:snapshot_fixture) { JSON.parse(File.read("spec/fixtures/snapshot.json")) }

  describe "#create_snapshot" do
    let(:response) { OpenStruct.new(body: snapshot_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("collections/test_collection/snapshots")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.create_snapshot(
        collection_name: "test_collection"
      )
      expect(response.dig('status')).to eq('ok')
      expect(response.dig('result', 'name')).to eq("test_collection-6106351684939824381-2023-04-06-20-43-03.snapshot")
    end
  end

  describe "#delete_snapshot" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:delete)
        .with("collections/test_collection/snapshots/test_collection-6106351684939824381-2023-04-06-20-43-03.snapshot")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.delete_snapshot(
        collection_name: "test_collection",
        snapshot_name: "test_collection-6106351684939824381-2023-04-06-20-43-03.snapshot"
      )
      expect(response.dig('status')).to eq('ok')
      expect(response.dig('result')).to eq(true)
    end
  end

  describe "#download_snapshot" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("collections/test_collection/snapshots/test_collection-6106351684939824381-2023-04-06-20-43-03.snapshot")
        .and_return(response)
      
      allow(File).to receive(:open).with("/dir/snapshot.txt", 'wb+').and_return(999)
    end

    it "returns the schema" do
      response = collections.download_snapshot(
        collection_name: "test_collection",
        snapshot_name: "test_collection-6106351684939824381-2023-04-06-20-43-03.snapshot",
        filepath: "/dir/snapshot.txt"
      )
      expect(response).to eq(999)
    end
  end

  describe "#restore_snapshot" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("collections/test_collection/snapshots/recover")
        .and_return(response)
    end

    it "returns the schema" do
      response = collections.restore_snapshot(
        collection_name: "test_collection",
        filepath: "test_collection-6106351684939824381-2023-04-06-20-43-03.snapshot"
      )
      expect(response.dig('status')).to eq('ok')
      expect(response.dig('result')).to eq(true)
    end
  end
end
