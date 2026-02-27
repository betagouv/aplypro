# frozen_string_literal: true

require "rails_helper"
require "./spec/models/stats/shared_contexts"

RSpec.describe Omogen::Base do
  include_context "with the initialization of OMOGEN connection"

  before do
    allow_any_instance_of(described_class).to receive(:base_url).and_return("http://blablabla.fr") # rubocop:disable RSpec/AnyInstance
  end

  describe "#initialize" do
    it "fetches an access token" do
      expect(described_class.new.access_token).to eq("fake-token")
    end
  end

  describe "#auth_connection" do
    it "creates a connection with correct auth URL" do
      expect(described_class.new.resource_connection.url_prefix.to_s).to eq("http://blablabla.fr/")
    end
  end
end
