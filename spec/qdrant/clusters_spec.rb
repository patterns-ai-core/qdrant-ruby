# frozen_string_literal: true

require "spec_helper"

RSpec.describe Qdrant::Clusters do
  let(:client) {
    Qdrant::Client.new(
      url: "localhost:8080",
      api_key: "123"
    )
  }

  let(:cluster_fixture) { JSON.parse(File.read("spec/fixtures/cluster.json")) }

  let(:response) {
    Qdrant::Client::Response.new(nil, nil, cluster_fixture)
  }

  describe "#info" do
    before do
      allow_any_instance_of(Qdrant::Client::Connection).to receive(:get)
        .with("cluster")
        .and_return(response)
    end

    it "return the cluster info" do
      expect(client.clusters.info.dig("status")).to eq("ok")
    end
  end

  describe "#recover" do
    before do
      allow_any_instance_of(Qdrant::Client::Connection).to receive(:post)
        .with("cluster/recover")
        .and_return(response)
    end

    it "return the data" do
      expect(client.clusters.recover.dig("status")).to eq("ok")
    end
  end

  describe "#remove_peer" do
    let(:request) { Qdrant::Client::RequestData.new({}, nil) }

    before do
      allow_any_instance_of(Qdrant::Client::Connection).to receive(:delete)
        .with("cluster/peer/42") do |_connection, _path, &block|
          block.call(request)
          response
        end
    end

    it "deletes the peer" do
      expect(client.clusters.remove_peer(peer_id: 42, force: true).dig("status")).to eq("ok")
      expect(request.params).to eq("force" => true)
    end
  end
end
