# frozen_string_literal: true

require "spec_helper"
require "stringio"

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
    let(:response) { Qdrant::Client::Response.new(nil, nil, snapshot_fixture) }

    before do
      allow_any_instance_of(Qdrant::Client::Connection).to receive(:post)
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
    let(:response) { Qdrant::Client::Response.new(nil, nil, snapshots_fixture) }

    before do
      allow_any_instance_of(Qdrant::Client::Connection).to receive(:get)
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
    let(:response) { Qdrant::Client::Response.new(nil, nil, status_response_fixture) }

    before do
      allow_any_instance_of(Qdrant::Client::Connection).to receive(:delete)
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
    it "writes the downloaded snapshot bytes to the file" do
      snapshot_bytes = "01010101001"
      io = StringIO.new

      allow_any_instance_of(Qdrant::Client::Connection).to receive(:get)
        .with("snapshots/my-snapshot")
        .and_return(Qdrant::Client::Response.new(nil, nil, snapshot_bytes))
      allow(File).to receive(:open).with("/dir/snapshot.txt", "wb+").and_yield(io)

      bytes = snapshots.download(
        snapshot_name: "my-snapshot",
        filepath: "/dir/snapshot.txt"
      )

      expect(bytes).to eq(snapshot_bytes.bytesize)
      expect(io.string).to eq(snapshot_bytes)
    end
  end
end
