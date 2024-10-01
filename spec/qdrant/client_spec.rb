# frozen_string_literal: true

require "spec_helper"

RSpec.describe Qdrant::Client do
  let(:client) {
    Qdrant::Client.new(
      url: "localhost:8080",
      api_key: "123"
    )
  }

  describe "#initialize" do
    it "creates a client" do
      expect(client).to be_a(Qdrant::Client)
    end

    it "accepts a custom logger" do
      logger = Logger.new($stdout)
      client = Qdrant::Client.new(
        url: "localhost:8080",
        api_key: "123",
        logger: logger
      )
      expect(client.logger).to eq(logger)
    end
  end

  describe "#points" do
    it "returns an objects client" do
      expect(client.points).to be_a(Qdrant::Points)
    end
  end

  describe "#snapshots" do
    it "returns a backups client" do
      expect(client.snapshots).to be_a(Qdrant::Snapshots)
    end
  end

  describe "#clusters" do
    it "returns a clusters client" do
      expect(client.clusters).to be_a(Qdrant::Clusters)
    end
  end

  describe "#collections" do
    it "returns a collections client" do
      expect(client.collections).to be_a(Qdrant::Collections)
    end
  end

  describe "#service" do
    it "returns a services client" do
      expect(client.service).to be_a(Qdrant::Service)
    end
  end
end
