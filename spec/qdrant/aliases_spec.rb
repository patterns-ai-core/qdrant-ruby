# frozen_string_literal: true

require "spec_helper"

RSpec.describe Qdrant::Aliases do
  let(:client) {
    Qdrant::Client.new(
      url: "localhost:8080",
      api_key: "123"
    )
  }

  let(:aliases_fixture) { JSON.parse(File.read("spec/fixtures/aliases.json")) }

  describe "#list" do
    let(:response) {
      Qdrant::Client::Response.new(nil, nil, aliases_fixture)
    }

    before do
      allow_any_instance_of(Qdrant::Client::Connection).to receive(:get)
        .with(Qdrant::Aliases::PATH)
        .and_return(response)
    end

    it "return the nodes info" do
      expect(client.aliases).to be_a(Hash)
    end
  end
end
