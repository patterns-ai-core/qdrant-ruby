# frozen_string_literal: true

require "spec_helper"

RSpec.describe Qdrant::Snapshots do
  let(:client) {
    Qdrant::Client.new(
      url: "localhost:8080",
      api_key: "123"
    )
  }

  let(:snapshots) { client.snapshots }
  let(:snapshot_fixture) { JSON.parse(File.read("spec/fixtures/snapshot.json")) }
  let(:snapshots_fixture) { JSON.parse(File.read("spec/fixtures/snapshots.json")) }
  let(:status_response_fixture) { JSON.parse(File.read("spec/fixtures/status_response.json")) }

  describe "#create" do
    let(:response) { OpenStruct.new(body: snapshot_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with(Qdrant::Snapshots::PATH)
        .and_return(response)
    end

    it "creates the backup" do
      response = snapshots.create
      expect(response.dig("result", "name")).to eq("test_collection-6106351684939824381-2023-04-06-20-43-03.snapshot")
      expect(response["status"]).to eq("ok")
    end
  end

  describe "#list" do
    let(:response) { OpenStruct.new(body: snapshots_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with(Qdrant::Snapshots::PATH)
        .and_return(response)
    end

    it "restores the backup" do
      response = snapshots.list
      expect(response["result"].count).to eq(2)
      expect(response["status"]).to eq("ok")
    end
  end

  describe "#delete" do
    let(:response) { OpenStruct.new(body: status_response_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:delete)
        .with("snapshots/my-snapshot")
        .and_return(response)
    end

    it "returns the restore status" do
      response = snapshots.delete(
        snapshot_name: "my-snapshot"
      )
      expect(response["result"]).to eq(true)
      expect(response["status"]).to eq("ok")
    end
  end

  describe "#download" do
    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("snapshots/my-snapshot")
        .and_return("01010101001")

      allow(File).to receive(:open).with("/dir/snapshot.txt", "wb+").and_return(999)
    end

    it "returns the restore status" do
      response = snapshots.download(
        snapshot_name: "my-snapshot",
        filepath: "/dir/snapshot.txt"
      )
      expect(response).to eq(999) # Random number of bytes written
    end
  end
end
