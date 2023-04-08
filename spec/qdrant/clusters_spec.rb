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
    OpenStruct.new(body: cluster_fixture)
  }

  describe "#info" do
    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("cluster")
        .and_return(response)
    end

    it "return the cluster info" do
      expect(client.clusters.info.dig("status")).to eq("ok")
    end
  end

  describe "#recover" do
    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("cluster/recover")
        .and_return(response)
    end

    it "return the data" do
      expect(client.clusters.recover.dig("status")).to eq("ok")
    end
  end

  xdescribe "#remove_peer" do
  end
end
