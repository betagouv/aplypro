# frozen_string_literal: true

require "rails_helper"

RSpec.describe Keycloak::ApplyInvitationAttributesJob do
  let(:realm_name) { "test-realm" }
  let(:email) { "user@example.com" }
  let(:academy_codes) { ["06"] }
  let(:client) { instance_double(Keycloak::Client) }

  before do
    allow(Keycloak::Client).to receive(:new).and_return(client)
  end

  describe "#perform" do
    it "applies invitation attributes to the user in Keycloak" do
      allow(client).to receive(:add_aplypro_academie_resp_attributes)
        .with(realm_name, email, academy_codes)
        .and_return({ success: true, message: "User updated successfully" })

      described_class.perform_now(realm_name, email, academy_codes)

      expect(client).to have_received(:add_aplypro_academie_resp_attributes)
        .with(realm_name, email, academy_codes)
    end
  end
end
