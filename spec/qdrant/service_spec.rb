# frozen_string_literal: true

require "spec_helper"

RSpec.describe Qdrant::Service do
  let(:client) {
    Qdrant::Client.new(
      url: "localhost:8080",
      api_key: '123'
    )
  }

  describe "#telemetry" do
    let(:response) {
      OpenStruct.new(body: {
        "result": {
          "id": "11111",
          "app": {
            "name": "qdrant",
            "version": "1.1.0"
          }
        }
      })
    }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("telemetry")
        .and_return(response)
    end

    it "return the data" do
      expect(client.telemetry.dig(:result, :id)).to eq('11111')
    end
  end

  describe "#metrics" do
    let(:response) { OpenStruct.new(body: "metrics") }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("metrics")
        .and_return(response)
    end

    it "returns the data" do
      expect(client.metrics).to eq("metrics")
    end
  end

  let(:locks_fixture) { JSON.parse(File.read("spec/fixtures/locks.json")) }

  describe "#set_lock" do
    let(:response) { OpenStruct.new(body: locks_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:post)
        .with("locks")
        .and_return(response)
    end

    it "returns the data" do
      response = client.set_lock(
        write: true,
        error_message: "my error msg"
      )
      expect(response.dig('result', 'error_message')).to eq('my error msg')
      expect(response.dig('result', 'write')).to eq(true)
    end
  end

  describe "#locks" do
    let(:response) { OpenStruct.new(body: locks_fixture) }

    before do
      allow_any_instance_of(Faraday::Connection).to receive(:get)
        .with("locks")
        .and_return(response)
    end

    it "returns the data" do
      response = client.locks
      expect(response.dig('result', 'error_message')).to eq('my error msg')
      expect(response.dig('result', 'write')).to eq(true)
    end
  end
end
