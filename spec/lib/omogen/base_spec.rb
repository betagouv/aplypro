# frozen_string_literal: true

require "rails_helper"

# rubocop:disable RSpec/AnyInstance
RSpec.describe Omogen::Base do
  before do
    allow_any_instance_of(described_class).to receive(:base_url).and_return("http://base.fr")
    allow_any_instance_of(described_class).to receive(:auth_url).and_return("http://auth.fr")
    allow_any_instance_of(described_class).to receive(:auth_params).and_return({})

    stub_request(:post, "http://auth.fr/token")
      .to_return(
        status: 200,
        body: { access_token: "fake-token", expires_in: 300 }.to_json
      )
  end

  describe "#initialize" do
    it "fetches an access token" do
      expect(described_class.new.access_token).to eq("fake-token")
    end
  end

  describe "#auth_connection" do
    it "creates a connection with correct auth URL" do
      expect(described_class.new.resource_connection.url_prefix.to_s).to eq("http://base.fr/")
    end
  end
end
# rubocop:enable RSpec/AnyInstance
