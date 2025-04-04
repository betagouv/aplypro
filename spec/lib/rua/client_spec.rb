# frozen_string_literal: true

require "rails_helper"

RSpec.describe Rua::Client do
  before do
    stub_request(:post, "#{Rua::Client::RUA_KC_URL}/token")
      .with(
        body: {
          grant_type: "client_credentials",
          client_id: Rua::Client::RUA_KC_CLIENT_ID,
          client_secret: Rua::Client::RUA_KC_CLIENT_SECRET
        }
      )
      .to_return(
        status: 200,
        body: { access_token: "fake-token", expires_in: 300 }.to_json
      )
  end

  describe "#initialize" do
    it "fetches an access token" do
      client = described_class.new
      expect(client.access_token).to eq("fake-token")
    end
  end

  describe "#agent_info" do
    let(:email) { "test@example.com" }
    let(:agent_data) { { "id" => 123, "name" => "Test Agent", "email" => email } }

    before do
      stub_request(:get, "#{Rua::Client::RUA_RESOURCE_BASE_URL}/agents")
        .with(query: { email: email })
        .to_return(
          status: 200,
          body: agent_data.to_json
        )
    end

    it "retrieves agent information by email" do
      client = described_class.new
      result = client.agent_info(email)
      expect(result).to eq(agent_data)
    end
  end

  describe "#auth_connection" do
    it "creates a connection with correct auth URL" do
      client = described_class.new
      expect(client.auth_connection.url_prefix.to_s).to eq(Rua::Client::RUA_KC_URL)
    end
  end

  describe "#connection" do
    it "creates a connection with correct resource URL" do
      client = described_class.new
      expect(client.resource_connection.url_prefix.to_s).to eq(Rua::Client::RUA_RESOURCE_BASE_URL)
    end
  end
end
