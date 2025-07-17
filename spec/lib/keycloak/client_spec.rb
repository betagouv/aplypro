# frozen_string_literal: true

require "rails_helper"

RSpec.describe Keycloak::Client do
  before do
    allow(ENV).to receive(:fetch).with("KEYCLOAK_HOST").and_return("https://keycloak.example.com")
    allow(ENV).to receive(:fetch).with("KEYCLOAK_ADMIN").and_return("admin")
    allow(ENV).to receive(:fetch).with("KEYCLOAK_ADMIN_PASSWORD").and_return("admin_password")

    stub_request(:post, "https://keycloak.example.com/realms/master/protocol/openid-connect/token")
      .to_return(
        status: 200,
        body: { access_token: "fake-access-token", expires_in: 300 }.to_json,
        headers: { "Content-Type" => "application/json" }
      )
  end

  describe "#initialize" do
    it "authenticates and sets up connection" do
      client = described_class.new
      expect(client.access_token).to eq("fake-access-token")
      expect(client.connection).to be_a(Faraday::Connection)
    end
  end

  describe "#list_realms" do
    before do
      stub_request(:get, "https://keycloak.example.com/admin/realms")
        .to_return(
          status: 200,
          body: [{ "id" => "master", "realm" => "master", "enabled" => true }].to_json,
          headers: { "Content-Type" => "application/json" }
        )
    end

    it "retrieves list of realms" do
      client = described_class.new
      result = client.list_realms
      expect(result).to eq([{ "id" => "master", "realm" => "master", "enabled" => true }])
    end
  end

  describe "#delete_user" do
    before do
      stub_request(:delete, "https://keycloak.example.com/admin/realms/test-realm/users/user-123")
        .to_return(status: 204, body: "")
    end

    it "deletes user from specified realm" do
      client = described_class.new
      result = client.delete_user("test-realm", "user-123")
      expect(result).to eq("")
    end
  end

  describe "#remove_user_by_email" do
    context "when user exists and removal succeeds" do
      before do
        stub_request(:get, "https://keycloak.example.com/admin/realms/test-realm/users")
          .with(query: { email: "user@example.com" })
          .to_return(
            status: 200,
            body: [{ "id" => "user-123", "email" => "user@example.com" }].to_json,
            headers: { "Content-Type" => "application/json" }
          )

        stub_request(:delete, "https://keycloak.example.com/admin/realms/test-realm/users/user-123")
          .to_return(status: 204, body: "")
      end

      it "removes user successfully" do
        client = described_class.new
        result = client.remove_user_by_email("test-realm", "user@example.com")
        expect(result).to eq({ success: true, message: "User removed successfully" })
      end
    end

    context "when user does not exist" do
      before do
        stub_request(:get, "https://keycloak.example.com/admin/realms/test-realm/users")
          .with(query: { email: "nonexistent@example.com" })
          .to_return(status: 200, body: [].to_json, headers: { "Content-Type" => "application/json" })
      end

      it "returns user not found error" do
        client = described_class.new
        result = client.remove_user_by_email("test-realm", "nonexistent@example.com")
        expect(result).to eq({ success: false, error: "User not found" })
      end
    end
  end

  describe "error handling" do
    context "when environment variables are missing" do
      before do
        allow(ENV).to receive(:fetch).with("KEYCLOAK_HOST").and_raise(KeyError.new("key not found: \"KEYCLOAK_HOST\""))
      end

      it "raises error for missing KEYCLOAK_HOST" do
        expect { described_class.new }.to raise_error(KeyError, "key not found: \"KEYCLOAK_HOST\"")
      end
    end
  end
end
