# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

RSpec.describe Omogen::Rua do
  include_context "with the initialization of OMOGEN connection"

  describe "#agent_info" do
    let(:email) { "test@example.com" }
    let(:agent_data) { { "id" => 123, "name" => "Test Agent", "email" => email } }

    before do
      stub_request(:get, "#{ENV.fetch('RUA_RESOURCE_BASE_URL')}/agents")
        .with(query: { email: email })
        .to_return(
          status: 200,
          body: agent_data.to_json
        )
    end

    it "retrieves agent information by email" do
      expect(described_class.new.agent_info(email)).to eq(agent_data)
    end
  end

  describe "#connection" do
    it "creates a connection with correct resource URL" do
      expect(described_class.new.resource_connection.url_prefix.to_s).to eq(ENV.fetch("RUA_RESOURCE_BASE_URL"))
    end
  end
end
